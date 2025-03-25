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

pub const FloatRect = @import("float_rect.zig").FloatRect;
pub const Rect = @import("rect.zig").Rect;

pub fn set_main_ready() void {
    sdl.SDL_SetMainReady();
}

pub fn get_error() [*c]const u8 {
    return sdl.SDL_GetError();
}
