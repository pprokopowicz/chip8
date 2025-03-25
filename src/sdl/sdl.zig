const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const Window = sdl.struct_SDL_Window;
pub const Renderer = sdl.struct_SDL_Renderer;
pub const Texture = sdl.struct_SDL_Texture;

pub const FloatRect = sdl.SDL_FRect;
pub const Rect = sdl.SDL_Rect;
pub const PixelFormat = @import("pixel_format.zig").PixelFormat;
pub const TextureAccess = @import("texture_access.zig").TextureAccess;
pub const ScaleMode = @import("scale_mode.zig").ScaleMode;

pub fn set_main_ready() void {
    sdl.SDL_SetMainReady();
}

pub fn create_window(title: [*c]const u8, width: u32, height: u32, flags: u64) ?*Window {
    const w: c_int = @intCast(width);
    const h: c_int = @intCast(height);
    const window = sdl.SDL_CreateWindow(title, w, h, flags);

    return window;
}

pub fn destroy_window(window: ?*Window) void {
    sdl.SDL_DestroyWindow(window);
}

pub fn create_renderer(window: ?*Window, name: [*c]const u8) ?*Renderer {
    return sdl.SDL_CreateRenderer(window, name);
}

pub fn render_clear(renderer: ?*Renderer) bool {
    return sdl.SDL_RenderClear(renderer);
}

pub fn render_present(renderer: ?*Renderer) bool {
    return sdl.SDL_RenderPresent(renderer);
}

pub fn destroy_renderer(renderer: ?*Renderer) void {
    sdl.SDL_DestroyRenderer(renderer);
}

pub fn create_texture(renderer: ?*Renderer, format: PixelFormat, access: TextureAccess, width: u32, height: u32) [*c]Texture {
    const w: c_int = @intCast(width);
    const h: c_int = @intCast(height);
    const access_int = @intFromEnum(access);
    const format_int = @intFromEnum(format);

    const texture = sdl.SDL_CreateTexture(renderer, format_int, access_int, w, h);

    return texture;
}

pub fn lock_texture(texture: ?*Texture, rect: ?*Rect, pixels: *?[*]u32, pitch: *u32) bool {
    const pixels_cast = @as([*c]?*anyopaque, @ptrCast(pixels));
    return sdl.SDL_LockTexture(texture, rect, pixels_cast, @ptrCast(pitch));
}

pub fn unlock_texture(texture: ?*Texture) void {
    sdl.SDL_UnlockTexture(texture);
}

pub fn set_texture_scale_mode(texture: ?*Texture, scale_mode: ScaleMode) bool {
    const scale_mode_int = @intFromEnum(scale_mode);
    return sdl.SDL_SetTextureScaleMode(texture, scale_mode_int);
}

pub fn render_texture(renderer: ?*Renderer, texture: ?*Texture, source_rect: ?*FloatRect, destination_rect: ?*FloatRect) bool {
    return sdl.SDL_RenderTexture(renderer, texture, source_rect, destination_rect);
}

pub fn destroy_texture(texture: ?*Texture) void {
    sdl.SDL_DestroyTexture(texture);
}

pub fn get_error() [*c]const u8 {
    return sdl.SDL_GetError();
}
