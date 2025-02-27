const cpu_core = @import("cpu-core");
const display_core = @import("display");
const std = @import("std");
const arguments = @import("arguments.zig");
const log = std.log;

pub fn main() !void {
    const path = try arguments.file_path_from_args();

    var chip8 = cpu_core.Chip8.new();
    try chip8.load(path);

    const display = try display_core.Display.new();
    defer display.quit();

    const slow_factor = 0.5;

    var quit = false;
    while (!quit) {
        chip8.emulate_cycle();

        parse_event(display, &quit);

        if (chip8.should_draw) {
            display.render(&chip8.vram);
        }

        std.time.sleep(12 * 1000 * 1000 * slow_factor);
    }
}

fn parse_event(display: display_core.Display, quit: *bool) void {
    var event: display_core.DisplayEvent = display_core.DisplayEvent.none;
    display.parse_event(&event);

    switch (event) {
        .quit => quit.* = true,
        .key_down => |key_code| log.info("Key down: {}", .{key_code}),
        .key_up => |key_code| log.info("Key up {}", .{key_code}),
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
