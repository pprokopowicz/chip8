const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const Window = sdl.struct_SDL_Window;

pub fn create_window(title: [*c]const u8, width: u32, height: u32, flags: u64) ?*Window {
    const w: c_int = @intCast(width);
    const h: c_int = @intCast(height);
    const window = sdl.SDL_CreateWindow(title, w, h, flags);

    return window;
}

pub fn destroy_window(window: ?*Window) void {
    sdl.SDL_DestroyWindow(window);
}
