const cpu_core = @import("cpu-core");
const display_core = @import("display");
const keypad_core = @import("keypad");
const std = @import("std");
const arguments = @import("arguments.zig");
const log = std.log;

const CLOCK_SPEED = 500;
const ns_per_us = 1000;
const ns_per_ms = 1000 * ns_per_us;
const ns_per_s = 1000 * ns_per_ms;
const SLEEP_TIME = ns_per_s / CLOCK_SPEED;

pub fn main() !void {
    const path = try arguments.file_path_from_args();

    var cpu = cpu_core.Chip8.new();
    try cpu.load(path);

    const display = try display_core.Display.new();
    defer display.quit();

    var quit = false;
    while (!quit) {
        cpu.emulate_cycle();

        parse_event(display, &cpu.keypad, &quit);

        if (cpu.should_draw) {
            display.render(&cpu.vram);
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
