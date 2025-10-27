const sdl = @import("sdl.zig").sdl;

pub const TextureAccess = enum(c_uint) {
    static = sdl.SDL_TEXTUREACCESS_STATIC,
    streaming = sdl.SDL_TEXTUREACCESS_STREAMING,
    target = sdl.SDL_TEXTUREACCESS_TARGET,
};
