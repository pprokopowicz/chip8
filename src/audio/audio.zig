const sdl = @import("sdl");
const std = @import("std");
const log = std.log;
const AudioError = @import("audio_error.zig").AudioError;

pub const Audio = struct {
    stream: *sdl.AudioStream,

    pub fn new() !Audio {
        const device_id = sdl.AudioDeviceDefaultPlayback;

        const stream = try audio_stream(device_id);
        errdefer sdl.destroy_audio_stream(stream);

        log.info("New Audio initialized!", .{});

        return Audio{ .stream = stream };
    }

    fn audio_stream(device_id: u32) !*sdl.AudioStream {
        const spec = sdl.AudioSpec{
            .format = sdl.AudioU8,
            .channels = 1,
            .freq = 48000,
        };

        const stream_optional = sdl.open_audio_device_stream(device_id, &spec);

        if (stream_optional) |stream| {
            return stream;
        } else {
            const sdl_error = sdl.get_error();
            log.warn("Audio error: {s}", .{sdl_error});
            return AudioError.UnableToOpenSteam;
        }
    }

    pub fn play(self: Audio) void {
        var buf: [800]u8 = [1]u8{1} ** 800;
        const buf_many_ptr: ?[*]u8 = &buf;

        // _ = sdl2.SDL_PutAudioStreamData(self.stream, @as(?*const anyopaque, @ptrCast(&buf_many_ptr)), 3000);
        _ = sdl.put_audio_stream_data(self.stream, @as(?*const anyopaque, @ptrCast(&buf_many_ptr)), 3000);
        _ = sdl.resume_audio_stream_device(self.stream);
    }

    pub fn quit(self: Audio) void {
        _ = sdl.flush_audio_stream(self.stream);
        _ = sdl.pause_audio_stream_device(self.stream);
        sdl.destroy_audio_stream(self.stream);
        sdl.close_audio_device(sdl.AudioDeviceDefaultPlayback);
    }
};
