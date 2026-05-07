const std = @import("std");
const cartridge = @import("cartridge");
const constant = @import("constant");
const opcode = @import("opcode_execution.zig");
const font_set = @import("font.zig").font_set;
const log = std.log;

const MEMORY_SIZE = 4096;
const REGISTER_SIZE = 16;
const STACK_SIZE = 16;
const KEYPAD_SIZE = constant.KEYPAD_SIZE;
const DISPLAY_HEIGHT = constant.INTERNAL_DISPLAY_HEIGHT;
const DISPLAY_WIDTH = constant.INTERNAL_DISPLAY_WIDTH;
const VRAM_SIZE = constant.VRAM_SIZE;

pub const Chip8 = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    opcode: u16,
    memory: [MEMORY_SIZE]u8,
    registers: [REGISTER_SIZE]u8,
    stack: [STACK_SIZE]u16,
    vram: [VRAM_SIZE]u1,
    keypad: [KEYPAD_SIZE]u1,
    index_register: u16,
    program_counter: u16,
    stack_pointer: u16,
    delay_timer: u8,
    sound_timer: u8,
    should_draw: bool,
    should_play_sound: bool,

    pub fn new(allocator: std.mem.Allocator, io: std.Io) Chip8 {
        log.info("New Chip8 CPU initialized!", .{});

        return Chip8{
            .allocator = allocator,
            .io = io,
            .opcode = 0,
            .memory = font_set ++ std.mem.zeroes([MEMORY_SIZE - font_set.len]u8),
            .registers = std.mem.zeroes([REGISTER_SIZE]u8),
            .stack = std.mem.zeroes([STACK_SIZE]u16),
            .vram = std.mem.zeroes([VRAM_SIZE]u1),
            .keypad = std.mem.zeroes([KEYPAD_SIZE]u1),
            .index_register = 0,
            .program_counter = 0x200,
            .stack_pointer = 0,
            .delay_timer = 0,
            .sound_timer = 0,
            .should_draw = false,
            .should_play_sound = false,
        };
    }

    pub fn load(self: *Chip8, path: []u8) !void {
        errdefer {
            log.warn("Failed to load file at path: {s}", .{path});
        }

        log.info("Trying to load file at path: {s}", .{path});

        const data = try cartridge.fileData(path, self.allocator, self.io);
        defer self.allocator.free(data);

        for (data, 0..data.len) |value, index| {
            self.memory[index + 512] = value;
        }
    }

    pub fn emulateCycle(self: *Chip8) void {
        self.should_draw = false;
        self.should_play_sound = false;

        self.fetchOpcode();
        self.executeOpcode();

        self.decreaseDelayTimer();
        self.checkSoundTimer();
    }

    fn fetchOpcode(self: *Chip8) void {
        const lhs: u16 = @intCast(self.memory[self.program_counter]);
        const rhs: u16 = @intCast(self.memory[self.program_counter + 1]);

        self.opcode = (lhs << 8) | rhs;
    }

    fn decreaseDelayTimer(self: *Chip8) void {
        if (self.delay_timer > 0) {
            self.delay_timer -= 1;
        }
    }

    fn checkSoundTimer(self: *Chip8) void {
        if (self.sound_timer > 0) {
            if (self.sound_timer == 1) {
                self.should_play_sound = true;
            }

            self.sound_timer -= 1;
        }
    }

    fn decodedOpcode(self: Chip8) u16 {
        return self.opcode & 0xF000;
    }

    fn executeOpcode(self: *Chip8) void {
        switch (self.decodedOpcode()) {
            0x0000 => {
                const additional_value = self.opcode & 0x000F;
                switch (additional_value) {
                    0x0000 => opcode.op00e0(self),
                    0x000E => opcode.op00ee(self),
                    else => self.unknownOpcode(),
                }
            },
            0x1000 => opcode.op1nnn(self),
            0x2000 => opcode.op2nnn(self),
            0x3000 => opcode.op3xnn(self),
            0x4000 => opcode.op4xnn(self),
            0x5000 => opcode.op5xy0(self),
            0x6000 => opcode.op6xnn(self),
            0x7000 => opcode.op7xnn(self),
            0x8000 => {
                const additional_value = self.opcode & 0x000F;
                switch (additional_value) {
                    0x0000 => opcode.op8xy0(self),
                    0x0001 => opcode.op8xy1(self),
                    0x0002 => opcode.op8xy2(self),
                    0x0003 => opcode.op8xy3(self),
                    0x0004 => opcode.op8xy4(self),
                    0x0005 => opcode.op8xy5(self),
                    0x0006 => opcode.op8xy6(self),
                    0x0007 => opcode.op8xy7(self),
                    0x000E => opcode.op8xye(self),
                    else => self.unknownOpcode(),
                }
            },
            0x9000 => opcode.op9xy0(self),
            0xA000 => opcode.opannn(self),
            0xB000 => opcode.opbnnn(self),
            0xC000 => opcode.opcxnn(self),
            0xD000 => opcode.opdxyn(self),
            0xE000 => {
                const additional_value = self.opcode & 0x00FF;
                switch (additional_value) {
                    0x009E => opcode.opex9e(self),
                    0x00A1 => opcode.opexa1(self),
                    else => self.unknownOpcode(),
                }
            },
            0xF000 => {
                const additional_value = self.opcode & 0x00FF;
                switch (additional_value) {
                    0x0007 => opcode.opfx07(self),
                    0x000A => opcode.opfx0a(self),
                    0x0015 => opcode.opfx15(self),
                    0x0018 => opcode.opfx18(self),
                    0x001E => opcode.opfx1e(self),
                    0x0029 => opcode.opfx29(self),
                    0x0033 => opcode.opfx33(self),
                    0x0055 => opcode.opfx55(self),
                    0x0065 => opcode.opfx65(self),
                    else => self.unknownOpcode(),
                }
            },
            else => self.unknownOpcode(),
        }
    }

    fn unknownOpcode(self: *Chip8) void {
        log.warn("Unknown opcode: 0x{X}!", .{self.opcode});
        self.program_counter += 2;
    }
};
