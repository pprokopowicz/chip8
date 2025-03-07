const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});
const log = @import("std").log;

const SubsystemError = error{
    FailedToInitialize,
};

pub const Subsystems = struct {
    pub fn new() !Subsystems {
        if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_AUDIO)) {
            const err = sdl.SDL_GetError();
            log.warn("Failed to initialize subsystems with error: {s}", .{err});
            return SubsystemError.FailedToInitialize;
        }

        return Subsystems{};
    }

    pub fn quit(self: Subsystems) void {
        _ = self;
        sdl.SDL_Quit();
    }
};
