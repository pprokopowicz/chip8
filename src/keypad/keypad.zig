const std = @import("std");
const constant = @import("constant");
const log = std.log;
const sdl = @import("sdl");

const KEYPAD_SIZE = constant.KEYPAD_SIZE;

pub fn parseKeyDown(key_code: u32, keypad: *[KEYPAD_SIZE]u1) void {
    const index_optional = indexFromKeyCode(key_code);

    if (index_optional) |index| {
        keypad[index] = 1;
    }
}

pub fn parseKeyUp(key_code: u32, keypad: *[KEYPAD_SIZE]u1) void {
    const index_optional = indexFromKeyCode(key_code);

    if (index_optional) |index| {
        keypad[index] = 0;
    }
}

fn indexFromKeyCode(key_code: u32) ?usize {
    const scan_code = sdl.scanCodeFrom(key_code);

    return switch (scan_code) {
        sdl.ScanCode.x => 0,
        sdl.ScanCode._1 => 1,
        sdl.ScanCode._2 => 2,
        sdl.ScanCode._3 => 3,
        sdl.ScanCode.q => 4,
        sdl.ScanCode.w => 5,
        sdl.ScanCode.e => 6,
        sdl.ScanCode.a => 7,
        sdl.ScanCode.s => 8,
        sdl.ScanCode.d => 9,
        sdl.ScanCode.z => 10,
        sdl.ScanCode.c => 11,
        sdl.ScanCode._4 => 12,
        sdl.ScanCode.r => 13,
        sdl.ScanCode.f => 14,
        sdl.ScanCode.v => 15,
        else => null,
    };
}
