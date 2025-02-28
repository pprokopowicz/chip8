const std = @import("std");
const DisplayConfig = @import("display").DisplayConfig;
const log = std.log;

const ArgumentError = error{
    TooManyArguments,
    NotEnoughArguments,
};

pub const Config = struct {
    file_path: []u8,
    display_config: DisplayConfig,
};

pub fn file_path_from_args() ![]u8 {
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
