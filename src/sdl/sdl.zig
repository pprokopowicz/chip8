pub const sdl = @import("SDL3");

const window_mod = @import("window.zig");
pub const Window = window_mod.Window;
pub const createWindow = window_mod.createWindow;
pub const destroyWindow = window_mod.destroyWindow;

const render_mod = @import("render.zig");
pub const Renderer = render_mod.Renderer;
pub const createRenderer = render_mod.createRenderer;
pub const renderClear = render_mod.renderClear;
pub const renderTexture = render_mod.renderTexture;
pub const renderPresent = render_mod.renderPresent;
pub const destroyRenderer = render_mod.destroyRenderer;

const texture_mod = @import("texture.zig");
pub const Texture = texture_mod.Texture;
pub const createTexture = texture_mod.createTexture;
pub const lockTexture = texture_mod.lockTexture;
pub const unlockTexture = texture_mod.unlockTexture;
pub const setTextureScaleMode = texture_mod.setTextureScaleMode;
pub const destroyTexture = texture_mod.destroyTexture;

pub const PixelFormat = @import("pixel_format.zig").PixelFormat;
pub const TextureAccess = @import("texture_access.zig").TextureAccess;
pub const ScaleMode = @import("scale_mode.zig").ScaleMode;

const scan_code_mod = @import("scan_code.zig");
pub const ScanCode = scan_code_mod.ScanCode;
pub const scanCodeFrom = scan_code_mod.scanCodeFrom;

const init_mod = @import("init.zig");
pub const init = init_mod.init;
pub const Init = init_mod.Init;

pub const FloatRect = @import("float_rect.zig").FloatRect;
pub const Rect = @import("rect.zig").Rect;

pub const AudioU8 = sdl.SDL_AUDIO_U8;

const audio_device_mod = @import("audio_device.zig");
pub const AudioDeviceDefaultPlayback = audio_device_mod.AudioDeviceDefaultPlayback;
pub const closeAudioDevice = audio_device_mod.closeAudioDevice;

const audio_spec_mod = @import("audio_spec.zig");
pub const AudioSpec = audio_spec_mod.AudioSpec;

const audio_stream_mod = @import("audio_stream.zig");
pub const AudioStream = audio_stream_mod.AudioStream;
pub const openAudioDeviceStream = audio_stream_mod.openAudioDeviceStream;
pub const resumeAudioStreamDevice = audio_stream_mod.resumeAudioStreamDevice;
pub const putAudioStreamData = audio_stream_mod.putAudioStreamData;
pub const destroyAudioStream = audio_stream_mod.destroyAudioStream;
pub const flushAudioStream = audio_stream_mod.flushAudioStream;
pub const pauseAudioStreamDevice = audio_stream_mod.pauseAudioStreamDevice;

pub const event_mod = @import("event.zig");
pub const Event = event_mod.Event;
pub const EventType = event_mod.EventType;
pub const pollEvent = event_mod.pollEvent;

pub fn setMainReady() void {
    sdl.SDL_SetMainReady();
}

pub fn getError() [*c]const u8 {
    return sdl.SDL_GetError();
}

pub fn quit() void {
    sdl.SDL_Quit();
}
