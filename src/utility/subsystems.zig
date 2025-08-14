const sdl = @import("sdl");
const log = @import("std").log;

const SubsystemError = error{
    FailedToInitialize,
};

pub const Subsystems = struct {
    pub fn new() !Subsystems {
        const flags = [_]sdl.Init{ .audio, .video };
        if (!sdl.init(&flags)) {
            const err = sdl.get_error();
            log.warn("Failed to initialize subsystems with error: {s}", .{err});
            return SubsystemError.FailedToInitialize;
        }

        return Subsystems{};
    }

    pub fn quit(self: Subsystems) void {
        _ = self;
        sdl.quit();
    }
};
