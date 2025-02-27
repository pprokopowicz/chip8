const cpu_core = @import("cpu-core");
const std = @import("std");
const log = std.log;

pub fn main() !void {
    // setup graphics
    // setup inputs

    const path = try file_path_from_args();

    var chip8 = cpu_core.Chip8.new();
    try chip8.load(path);

    while (true) {
        chip8.emulate_cycle();

        if (chip8.should_draw) {
            debug_render(chip8);
        }
    }
}

const ArgumentError = error{
    TooManyArguments,
    NotEnoughArguments,
};

fn file_path_from_args() ![]u8 {
    const args = std.os.argv;

    log.info("There are {d} args:", .{args.len});
    for (args) |arg| {
        log.info("  {s}", .{arg});
    }

    if (args.len < 2) {
        log.err("Not enough arguments passed!", .{});
        return ArgumentError.NotEnoughArguments;
    } else if (args.len > 2) {
        log.err("Too many arguments passed!", .{});
        return ArgumentError.TooManyArguments;
    }

    const file_path = std.mem.span(args[1]);

    return file_path;
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
