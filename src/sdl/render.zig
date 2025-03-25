const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const Window = @import("window.zig").Window;
const Texture = @import("texture.zig").Texture;
const FloatRect = @import("float_rect.zig").FloatRect;

pub const Renderer = sdl.struct_SDL_Renderer;

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

pub fn render_texture(renderer: ?*Renderer, texture: ?*Texture, source_rect: ?*FloatRect, destination_rect: ?*FloatRect) bool {
    return sdl.SDL_RenderTexture(renderer, texture, source_rect, destination_rect);
}
