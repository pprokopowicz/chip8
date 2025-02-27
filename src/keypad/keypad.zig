const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});
const std = @import("std");
const log = std.log;

pub fn parse_key_down(key_code: u32, keypad: *[16]u1) void {
    const index = index_from_key_code(key_code);
    keypad[index] = 1;
}

pub fn parse_key_up(key_code: u32, keypad: *[16]u1) void {
    const index = index_from_key_code(key_code);
    keypad[index] = 0;
}

fn index_from_key_code(key_code: u32) usize {
    const c_key_code: c_int = @intCast(key_code);

    return switch (c_key_code) {
        sdl.SDL_SCANCODE_X => 0,
        sdl.SDL_SCANCODE_1 => 1,
        sdl.SDL_SCANCODE_2 => 2,
        sdl.SDL_SCANCODE_3 => 3,
        sdl.SDL_SCANCODE_Q => 4,
        sdl.SDL_SCANCODE_W => 5,
        sdl.SDL_SCANCODE_E => 6,
        sdl.SDL_SCANCODE_A => 7,
        sdl.SDL_SCANCODE_S => 8,
        sdl.SDL_SCANCODE_D => 9,
        sdl.SDL_SCANCODE_Z => 10,
        sdl.SDL_SCANCODE_C => 11,
        sdl.SDL_SCANCODE_4 => 12,
        sdl.SDL_SCANCODE_R => 13,
        sdl.SDL_SCANCODE_F => 14,
        sdl.SDL_SCANCODE_V => 15,
        else => 0,
    };
}
