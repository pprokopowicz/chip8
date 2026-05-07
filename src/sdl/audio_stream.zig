const sdl = @import("sdl.zig").sdl;
const audio_spec = @import("audio_spec.zig");

pub const AudioStream = sdl.SDL_AudioStream;

pub fn openAudioDeviceStream(device_id: u32, spec: [*c]const audio_spec.AudioSpec) ?*AudioStream {
    return sdl.SDL_OpenAudioDeviceStream(device_id, spec, null, null);
}

pub fn resumeAudioStreamDevice(audio_stream: ?*AudioStream) bool {
    return sdl.SDL_ResumeAudioStreamDevice(audio_stream);
}

pub fn putAudioStreamData(audio_stream: ?*AudioStream, buffer: ?*const anyopaque, length: u32) bool {
    const c_length: c_int = @intCast(length);
    return sdl.SDL_PutAudioStreamData(audio_stream, buffer, c_length);
}

pub fn destroyAudioStream(audio_stream: ?*AudioStream) void {
    sdl.SDL_DestroyAudioStream(audio_stream);
}

pub fn flushAudioStream(audio_stream: ?*AudioStream) bool {
    return sdl.SDL_FlushAudioStream(audio_stream);
}

pub fn pauseAudioStreamDevice(audio_stream: ?*AudioStream) bool {
    return sdl.SDL_PauseAudioStreamDevice(audio_stream);
}
