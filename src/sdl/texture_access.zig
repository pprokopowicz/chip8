const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const TextureAccess = enum(c_uint) {
    static = sdl.SDL_TEXTUREACCESS_STATIC,
    streaming = sdl.SDL_TEXTUREACCESS_STREAMING,
    target = sdl.SDL_TEXTUREACCESS_TARGET,
};
