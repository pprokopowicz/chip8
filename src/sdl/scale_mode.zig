const sdl = @import("sdl.zig").sdl;

pub const ScaleMode = enum(c_int) {
    nearest = sdl.SDL_SCALEMODE_NEAREST,
    linear = sdl.SDL_SCALEMODE_LINEAR,
};
