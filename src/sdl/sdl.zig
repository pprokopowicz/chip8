const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const window_mod = @import("window.zig");
pub const Window = window_mod.Window;
pub const create_window = window_mod.create_window;
pub const destroy_window = window_mod.destroy_window;

const render_mod = @import("render.zig");
pub const Renderer = render_mod.Renderer;
pub const create_renderer = render_mod.create_renderer;
pub const render_clear = render_mod.render_clear;
pub const render_texture = render_mod.render_texture;
pub const render_present = render_mod.render_present;
pub const destroy_renderer = render_mod.destroy_renderer;

const texture_mod = @import("texture.zig");
pub const Texture = texture_mod.Texture;
pub const create_texture = texture_mod.create_texture;
pub const lock_texture = texture_mod.lock_texture;
pub const unlock_texture = texture_mod.unlock_texture;
pub const set_texture_scale_mode = texture_mod.set_texture_scale_mode;
pub const destroy_texture = texture_mod.destroy_texture;

pub const PixelFormat = @import("pixel_format.zig").PixelFormat;
pub const TextureAccess = @import("texture_access.zig").TextureAccess;
pub const ScaleMode = @import("scale_mode.zig").ScaleMode;

const scan_code_mod = @import("scan_code.zig");
pub const ScanCode = scan_code_mod.ScanCode;
pub const scan_code_from = scan_code_mod.scan_code_from;

const init_mod = @import("init.zig");
pub const init = init_mod.init;
pub const Init = init_mod.Init;

pub const FloatRect = @import("float_rect.zig").FloatRect;
pub const Rect = @import("rect.zig").Rect;

pub const AudioU8 = sdl.SDL_AUDIO_U8;

pub const audio_device_mod = @import("audio_device.zig");
pub const AudioDeviceDefaultPlayback = audio_device_mod.AudioDeviceDefaultPlayback;
pub const close_audio_device = audio_device_mod.close_audio_device;

const audio_spec_mod = @import("audio_spec.zig");
pub const AudioSpec = audio_spec_mod.AudioSpec;

const audio_stream_mod = @import("audio_stream.zig");
pub const AudioStream = audio_stream_mod.AudioStream;
pub const open_audio_device_stream = audio_stream_mod.open_audio_device_stream;
pub const resume_audio_stream_device = audio_stream_mod.resume_audio_stream_device;
pub const put_audio_stream_data = audio_stream_mod.put_audio_stream_data;
pub const destroy_audio_stream = audio_stream_mod.destroy_audio_stream;
pub const flush_audio_stream = audio_stream_mod.flush_audio_stream;
pub const pause_audio_stream_device = audio_stream_mod.pause_audio_stream_device;

pub const event_mod = @import("event.zig");
pub const Event = event_mod.Event;
pub const EventType = event_mod.EventType;
pub const poll_event = event_mod.poll_event;

pub fn set_main_ready() void {
    sdl.SDL_SetMainReady();
}

pub fn get_error() [*c]const u8 {
    return sdl.SDL_GetError();
}

pub fn quit() void {
    sdl.SDL_Quit();
}
