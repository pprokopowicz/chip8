const constant = @import("constant");
const cpu_core = @import("cpu-core");
const display_core = @import("display");
const keypad_core = @import("keypad");
const input_event = @import("input-event");
const std = @import("std");
const arguments = @import("arguments.zig");
const log = std.log;

const SLEEP_TIME = constant.NS_PER_S / constant.CLOCK_SPEED;

pub fn main() !void {
    const path = try arguments.file_path_from_args();

    var cpu = cpu_core.Chip8.new();
    try cpu.load(path);

    const display_config = display_core.DisplayConfig.new(
        constant.DEFAULT_DISPLAY_SCALE,
        constant.DEFAULT_FOREGROUND_COLOR,
        constant.DEFAULT_BACKGROUND_COLOR,
    );
    const display = try display_core.Display.new(display_config);
    defer display.quit();

    var quit = false;
    while (!quit) {
        cpu.emulate_cycle();

        parse_event(&cpu.keypad, &quit);

        if (cpu.should_draw) {
            display.render(&cpu.vram);
        }

        std.time.sleep(SLEEP_TIME);
    }
}

fn parse_event(keypad: *[constant.KEYPAD_SIZE]u1, quit: *bool) void {
    var event: input_event.InputEvent = input_event.InputEvent.none;
    input_event.parse_event(&event);

    switch (event) {
        .quit => quit.* = true,
        .key_down => |key_code| keypad_core.parse_key_down(key_code, keypad),
        .key_up => |key_code| keypad_core.parse_key_up(key_code, keypad),
        .none => {},
    }
}

fn debug_render(cpu: cpu_core.Chip8) void {
    var y: usize = 0;

    while (y < constant.INTERNAL_DISPLAY_HEIGHT) : (y += 1) {
        var x: usize = 0;
        while (x < constant.INTERNAL_DISPLAY_WIDTH) : (x += 1) {
            if (cpu.vram[y * constant.INTERNAL_DISPLAY_WIDTH + x] == 0) {
                std.debug.print(" ", .{});
            } else {
                std.debug.print("#", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
    std.debug.print("\n", .{});
}
