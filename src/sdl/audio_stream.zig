const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});
const audio_spec = @import("audio_spec.zig");

pub const AudioStream = sdl.SDL_AudioStream;

pub fn open_audio_device_stream(device_id: u32, spec: [*c]const audio_spec.AudioSpec) ?*AudioStream {
    return sdl.SDL_OpenAudioDeviceStream(device_id, spec, null, null);
}

pub fn resume_audio_stream_device(audio_stream: ?*AudioStream) bool {
    return sdl.SDL_ResumeAudioStreamDevice(audio_stream);
}

pub fn put_audio_stream_data(audio_stream: ?*AudioStream, buffer: ?*const anyopaque, length: u32) bool {
    const c_length: c_int = @intCast(length);
    return sdl.SDL_PutAudioStreamData(audio_stream, buffer, c_length);
}

pub fn destroy_audio_stream(audio_stream: ?*AudioStream) void {
    sdl.SDL_DestroyAudioStream(audio_stream);
}

pub fn flush_audio_stream(audio_stream: ?*AudioStream) bool {
    return sdl.SDL_FlushAudioStream(audio_stream);
}

pub fn pause_audio_stream_device(audio_stream: ?*AudioStream) bool {
    return sdl.SDL_PauseAudioStreamDevice(audio_stream);
}
