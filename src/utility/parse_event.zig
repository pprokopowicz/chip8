const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const InputEvent = union(enum) {
    quit: void,
    key_down: u32,
    key_up: u32,
    none: void,
};

pub fn parse_event(event: *InputEvent) void {
    var sdl_event: sdl.SDL_Event = undefined;

    while (sdl.SDL_PollEvent(&sdl_event)) {
        switch (sdl_event.type) {
            sdl.SDL_EVENT_QUIT => event.* = InputEvent.quit,
            sdl.SDL_EVENT_KEY_DOWN => {
                if (sdl_event.key.scancode == sdl.SDL_SCANCODE_ESCAPE) {
                    event.* = InputEvent.quit;
                } else {
                    event.* = InputEvent{ .key_down = key_code(sdl_event) };
                }
            },
            sdl.SDL_EVENT_KEY_UP => {
                event.* = InputEvent{ .key_up = key_code(sdl_event) };
            },
            else => event.* = InputEvent.none,
        }
    }
}

fn key_code(event: sdl.SDL_Event) u32 {
    return @intCast(event.key.scancode);
}
