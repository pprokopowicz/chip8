const sdl = @import("sdl");

pub const InputEvent = union(enum) {
    quit: void,
    key_down: u32,
    key_up: u32,
    none: void,
};

pub fn parse_event(event: *InputEvent) void {
    var sdl_event: sdl.Event = undefined;

    while (sdl.poll_event(&sdl_event)) {
        switch (sdl_event.event_type) {
            sdl.EventType.quit => event.* = InputEvent.quit,
            sdl.EventType.key_down => {
                if (sdl_event.scan_code == sdl.ScanCode.escape) {
                    event.* = InputEvent.quit;
                } else {
                    event.* = InputEvent{ .key_down = key_code(sdl_event) };
                }
            },
            sdl.EventType.key_up => {
                event.* = InputEvent{ .key_up = key_code(sdl_event) };
            },
            _ => event.* = InputEvent.none,
        }
    }
}

fn key_code(event: sdl.Event) u32 {
    return @intCast(@intFromEnum(event.scan_code));
}
