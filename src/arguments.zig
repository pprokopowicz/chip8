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

pub fn config() !Config {
    const args = std.os.argv;

    log.info("There are {d} args:", .{args.len});
    for (args) |arg| {
        log.info("  {s}", .{arg});
    }

    const file_path = try file_path_argument(args);
    const display_scale = try display_scale_argument(args);
    const foreground_color = try foreground_color_argument(args);
    const background_color = try background_color_argument(args);
    const is_audio_muted = audio_mute_argument(args);

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

fn file_path_argument(args: [][*:0]u8) ![]u8 {
    const file_path = try named_argument(FILE_PATH_NAME, args);

    if (file_path) |path| {
        return std.mem.span(path);
    } else {
        return ArgumentError.NoRomArgument;
    }
}

fn display_scale_argument(args: [][*:0]u8) !u32 {
    const scale_argument = try named_argument(DISPLAY_SCALE_NAME, args);

    if (scale_argument) |scale| {
        const scale_int = try int_from_string(u32, scale, 10);
        return scale_int;
    } else {
        return constant.DEFAULT_DISPLAY_SCALE;
    }
}

fn foreground_color_argument(args: [][*:0]u8) !u32 {
    const foreground_argument = try named_argument(FOREGROUND_NAME, args);

    if (foreground_argument) |foreground| {
        const foreground_int = try int_from_string(u32, foreground, 16);
        return add_alpha(foreground_int);
    } else {
        return constant.DEFAULT_FOREGROUND_COLOR;
    }
}

fn background_color_argument(args: [][*:0]u8) !u32 {
    const background_argument = try named_argument(BACKGROUND_NAME, args);

    if (background_argument) |background| {
        const background_int = try int_from_string(u32, background, 16);
        return add_alpha(background_int);
    } else {
        return constant.DEFAULT_BACKGROUND_COLOR;
    }
}

fn audio_mute_argument(args: [][*:0]u8) bool {
    for (args) |argument| {
        const cast_argument = std.mem.span(argument);

        if (std.mem.eql(u8, cast_argument, AUDIO_MUTE_NAME)) {
            return true;
        }
    }

    return false;
}

fn named_argument(name: []const u8, args: [][*:0]u8) !?[*:0]u8 {
    const value = for (args, 0..args.len) |argument, index| {
        const cast_argument = std.mem.span(argument);

        if (std.mem.eql(u8, cast_argument, name)) {
            const next = index + 1;
            if (next < args.len) {
                break args[next];
            } else {
                return ArgumentError.NoValueForArgument;
            }
        }
    } else null;

    return value;
}

fn add_alpha(color: u32) u32 {
    return (color << 8) + 0xFF;
}

fn int_from_string(T: type, buf: [*:0]u8, base: u8) !T {
    const cast_buf = std.mem.span(buf);
    const int_value = try std.fmt.parseInt(T, cast_buf, base);
    return int_value;
}
