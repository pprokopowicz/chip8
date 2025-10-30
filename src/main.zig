const std = @import("std");
const constant = @import("constant");
const keypad_core = @import("keypad");
const utility_core = @import("utility");

const arguments = @import("arguments.zig");

const Chip8 = @import("cpu-core").Chip8;
const Display = @import("display").Display;
const Audio = @import("audio").Audio;

const Subsystems = utility_core.Subsystems;
const InputEvent = utility_core.InputEvent;
const log = std.log;

const SLEEP_TIME = constant.NS_PER_S / constant.CLOCK_SPEED;

pub fn main() !void {
    const config = try arguments.config();

    const subsystems = try Subsystems.new();
    defer subsystems.quit();

    var cpu = Chip8.new();
    try cpu.load(config.file_path);

    const display = try Display.new(config.display_config);
    defer display.quit();

    const audio = try Audio.new(config.audio_config);
    defer audio.quit();

    var quit = false;

    while (!quit) {
        cpu.emulate_cycle();

        parse_event(&cpu.keypad, &quit);

        if (cpu.should_draw) {
            display.render(&cpu.vram);
        }

        if (cpu.should_play_sound) {
            audio.play();
        }

        std.Thread.sleep(SLEEP_TIME);
    }
}

fn parse_event(keypad: *[constant.KEYPAD_SIZE]u1, quit: *bool) void {
    var event: InputEvent = InputEvent.none;
    utility_core.parse_event(&event);

    switch (event) {
        .quit => quit.* = true,
        .key_down => |key_code| keypad_core.parse_key_down(key_code, keypad),
        .key_up => |key_code| keypad_core.parse_key_up(key_code, keypad),
        .none => {},
    }
}

fn debug_render(cpu: Chip8) void {
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
