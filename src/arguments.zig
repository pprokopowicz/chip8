const std = @import("std");
const constant = @import("constant");
const DisplayConfig = @import("display").DisplayConfig;
const AudioConfig = @import("audio").AudioConfig;
const log = std.log;

const ArgumentError = error{
    NoRomArgument,
    NoValueForArgument,
    OverMaxValue,
};

pub const Config = struct {
    file_path: []u8,
    display_config: DisplayConfig,
    audio_config: AudioConfig,

    fn new(file_path: []u8, display_config: DisplayConfig, audio_config: AudioConfig) Config {
        return Config{
            .file_path = file_path,
            .display_config = display_config,
            .audio_config = audio_config,
        };
    }
};

const FILE_PATH_NAME = "--rom";
const DISPLAY_SCALE_NAME = "--scale";
const FOREGROUND_NAME = "--foreground-color";
const BACKGROUND_NAME = "--background-color";
const AUDIO_MUTE_NAME = "--mute";
const Args = []const [:0]const u8;

pub fn config(args: Args) !Config {
    log.info("There are {d} args:", .{args.len});
    for (args) |arg| {
        log.info("\t\t{s}", .{arg});
    }

    const file_path = try filePathArgument(args);
    const display_scale = try displayScaleArgument(args);
    const foreground_color = try foregroundColorArgument(args);
    const background_color = try backgroundColorArgument(args);
    const is_audio_muted = audioMuteArgument(args);

    const display_config = DisplayConfig.new(
        display_scale,
        foreground_color,
        background_color,
    );

    const audio_config = AudioConfig.new(is_audio_muted);

    return Config.new(
        file_path,
        display_config,
        audio_config,
    );
}

fn filePathArgument(args: Args) ![]u8 {
    const file_path = try namedArgument(FILE_PATH_NAME, args);

    if (file_path) |path| {
        const slice: []u8 = @constCast(path);
        return slice;
    } else {
        return ArgumentError.NoRomArgument;
    }
}

fn displayScaleArgument(args: Args) !u32 {
    const scale_argument = try namedArgument(DISPLAY_SCALE_NAME, args);

    if (scale_argument) |scale| {
        const scale_int = try intFromString(u32, scale, 10);
        return scale_int;
    } else {
        return constant.DEFAULT_DISPLAY_SCALE;
    }
}

fn foregroundColorArgument(args: Args) !u32 {
    const foreground_argument = try namedArgument(FOREGROUND_NAME, args);

    if (foreground_argument) |foreground| {
        const foreground_int = try intFromString(u32, foreground, 16);
        return addAlpha(foreground_int);
    } else {
        return constant.DEFAULT_FOREGROUND_COLOR;
    }
}

fn backgroundColorArgument(args: Args) !u32 {
    const background_argument = try namedArgument(BACKGROUND_NAME, args);

    if (background_argument) |background| {
        const background_int = try intFromString(u32, background, 16);
        return addAlpha(background_int);
    } else {
        return constant.DEFAULT_BACKGROUND_COLOR;
    }
}

fn audioMuteArgument(args: Args) bool {
    for (args) |arg| {
        if (std.mem.eql(u8, arg, AUDIO_MUTE_NAME)) {
            return true;
        }
    }

    return false;
}

fn namedArgument(name: []const u8, args: Args) !?[:0]const u8 {
    var value_index: ?usize = null;
    for (args, 0..) |arg, index| {
        if (std.mem.eql(u8, arg, name)) {
            value_index = index + 1;
        }
    }

    if (value_index) |index| {
        if (index < args.len) {
            return args[index];
        } else {
            return ArgumentError.NoValueForArgument;
        }
    }

    return null;
}

fn addAlpha(color: u32) u32 {
    return (color << 8) + 0xFF;
}

fn intFromString(T: type, buf: [:0]const u8, base: u8) !T {
    const int_value = try std.fmt.parseInt(T, buf, base);
    return int_value;
}
