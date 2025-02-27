const cpu_core = @import("cpu-core");
const display_core = @import("display");
const keypad_core = @import("keypad");
const std = @import("std");
const arguments = @import("arguments.zig");
const log = std.log;

const CLOCK_SPEED = 500;
const NS_PER_US = 1000;
const NS_PER_MS = 1000 * NS_PER_US;
const NS_PER_S = 1000 * NS_PER_MS;
const SLEEP_TIME = NS_PER_S / CLOCK_SPEED;
const DISPLAY_REFRESH_RATE = 60;
const DRAW_TIME_DIFF = NS_PER_S / DISPLAY_REFRESH_RATE;

pub fn main() !void {
    const path = try arguments.file_path_from_args();

    var cpu = cpu_core.Chip8.new();
    try cpu.load(path);

    const display = try display_core.Display.new();
    defer display.quit();

    var draw_timestamp = std.time.nanoTimestamp();

    var quit = false;
    while (!quit) {
        cpu.emulate_cycle();

        parse_event(display, &cpu.keypad, &quit);

        const next_draw_timestamp = std.time.nanoTimestamp();

        if (cpu.should_draw and (next_draw_timestamp - draw_timestamp) >= DRAW_TIME_DIFF) {
            display.render(&cpu.vram);
            draw_timestamp = next_draw_timestamp;
        }

        std.time.sleep(SLEEP_TIME);
    }
}

fn parse_event(display: display_core.Display, keypad: *[16]u1, quit: *bool) void {
    var event: display_core.DisplayEvent = display_core.DisplayEvent.none;
    display.parse_event(&event);

    switch (event) {
        .quit => quit.* = true,
        .key_down => |key_code| keypad_core.parse_key_down(key_code, keypad),
        .key_up => |key_code| keypad_core.parse_key_up(key_code, keypad),
        .none => {},
    }
}

fn debug_render(cpu: cpu_core.Chip8) void {
    var y: usize = 0;

    while (y < 32) : (y += 1) {
        var x: usize = 0;
        while (x < 64) : (x += 1) {
            if (cpu.vram[y * 64 + x] == 0) {
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
