const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const Renderer = @import("render.zig").Renderer;
const PixelFormat = @import("pixel_format.zig").PixelFormat;
const TextureAccess = @import("texture_access.zig").TextureAccess;
const ScaleMode = @import("scale_mode.zig").ScaleMode;
const Rect = @import("rect.zig").Rect;

pub const Texture = sdl.struct_SDL_Texture;

pub fn create_texture(renderer: ?*Renderer, format: PixelFormat, access: TextureAccess, width: u32, height: u32) ?*Texture {
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

pub fn destroy_texture(texture: ?*Texture) void {
    sdl.SDL_DestroyTexture(texture);
}
