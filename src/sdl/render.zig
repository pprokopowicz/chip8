const sdl = @import("sdl.zig").sdl;
const Window = @import("window.zig").Window;
const Texture = @import("texture.zig").Texture;
const FloatRect = @import("float_rect.zig").FloatRect;

pub const Renderer = sdl.struct_SDL_Renderer;

pub fn createRenderer(window: ?*Window, name: [*c]const u8) ?*Renderer {
    return sdl.SDL_CreateRenderer(window, name);
}

pub fn renderClear(renderer: ?*Renderer) bool {
    return sdl.SDL_RenderClear(renderer);
}

pub fn renderPresent(renderer: ?*Renderer) bool {
    return sdl.SDL_RenderPresent(renderer);
}

pub fn destroyRenderer(renderer: ?*Renderer) void {
    sdl.SDL_DestroyRenderer(renderer);
}

pub fn renderTexture(renderer: ?*Renderer, texture: ?*Texture, source_rect: ?*FloatRect, destination_rect: ?*FloatRect) bool {
    return sdl.SDL_RenderTexture(renderer, texture, source_rect, destination_rect);
}
