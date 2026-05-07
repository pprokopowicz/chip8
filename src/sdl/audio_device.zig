const sdl = @import("sdl.zig").sdl;

pub const AudioDeviceDefaultPlayback = sdl.SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK;

pub fn closeAudioDevice(device_id: u32) void {
    sdl.SDL_CloseAudioDevice(device_id);
}
