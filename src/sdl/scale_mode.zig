const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const ScaleMode = enum(c_uint) {
    nearest = sdl.SDL_SCALEMODE_NEAREST,
    linear = sdl.SDL_SCALEMODE_LINEAR,
};
