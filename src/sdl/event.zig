const std = @import("std");
const sdl = @import("sdl.zig").sdl;
const ScanCode = @import("scan_code.zig").ScanCode;

pub const Event = struct {
    event_type: EventType,
    scan_code: ScanCode,
};

pub fn poll_event(event: *Event) bool {
    var sdl_event: sdl.SDL_Event = undefined;
    const return_val = sdl.SDL_PollEvent(&sdl_event);

    if (return_val) {
        const event_type: EventType = @enumFromInt(sdl_event.type);
        const scan_code: ScanCode = @enumFromInt(sdl_event.key.scancode);
        event.* = Event{ .event_type = event_type, .scan_code = scan_code };
    }

    return return_val;
}

pub const EventType = enum(c_int) {
    quit = sdl.SDL_EVENT_QUIT,
    key_down = sdl.SDL_EVENT_KEY_DOWN,
    key_up = sdl.SDL_EVENT_KEY_UP,
    _,
};
