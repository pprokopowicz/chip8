const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const Init = enum(c_uint) {
    audio = sdl.SDL_INIT_AUDIO,
    video = sdl.SDL_INIT_VIDEO,
    joystick = sdl.SDL_INIT_JOYSTICK,
    haptic = sdl.SDL_INIT_HAPTIC,
    gamepad = sdl.SDL_INIT_GAMEPAD,
    events = sdl.SDL_INIT_EVENTS,
    sensor = sdl.SDL_INIT_SENSOR,
    camera = sdl.SDL_INIT_CAMERA,
};

pub fn init(flags: []const Init) bool {
    var flags_int: c_uint = 0;

    for (flags) |flag| {
        const value = @intFromEnum(flag);
        flags_int |= value;
    }

    return sdl.SDL_Init(flags_int);
}
