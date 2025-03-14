const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
    @cInclude("SDL3/SDL_audio.h");
});
const std = @import("std");
const log = std.log;
const AudioError = @import("audio_error.zig").AudioError;

pub const Audio = struct {
    stream: *sdl.SDL_AudioStream,

    pub fn new() !Audio {
        const device_id = sdl.SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK;

        const stream = try audio_stream(device_id);
        errdefer sdl.SDL_DestroyAudioStream(stream);

        log.info("New Audio initialized!", .{});

        return Audio{ .stream = stream };
    }

    fn audio_stream(device_id: u32) !*sdl.SDL_AudioStream {
        const spec = sdl.SDL_AudioSpec{
            .format = sdl.SDL_AUDIO_U8,
            .channels = 1,
            .freq = 48000,
        };

        const stream_optional = sdl.SDL_OpenAudioDeviceStream(
            device_id,
            &spec,
            null,
            null,
        );

        if (stream_optional) |stream| {
            return stream;
        } else {
            const sdl_error = sdl.SDL_GetError();
            log.warn("Audio error: {s}", .{sdl_error});
            return AudioError.UnableToOpenSteam;
        }
    }

    pub fn play(self: Audio) void {
        var buf: [800]u8 = [1]u8{1} ** 800;
        const buf_many_ptr: ?[*]u8 = &buf;

        _ = sdl.SDL_PutAudioStreamData(self.stream, @as(?*const anyopaque, @ptrCast(&buf_many_ptr)), 3000);
        _ = sdl.SDL_ResumeAudioStreamDevice(self.stream);
    }

    pub fn quit(self: Audio) void {
        _ = sdl.SDL_FlushAudioStream(self.stream);
        _ = sdl.SDL_PauseAudioStreamDevice(self.stream);
        sdl.SDL_DestroyAudioStream(self.stream);
        sdl.SDL_CloseAudioDevice(sdl.SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK);
    }
};
