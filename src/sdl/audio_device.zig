const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const AudioDeviceDefaultPlayback = sdl.SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK;

pub fn close_audio_device(device_id: u32) void {
    sdl.SDL_CloseAudioDevice(device_id);
}
