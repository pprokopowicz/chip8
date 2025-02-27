const std = @import("std");
const cartridge = @import("cartridge");
const constant = @import("constant");
const font_set = @import("font.zig").font_set;
const opcode = @import("opcode_execution.zig");
const log = std.log;

const MEMORY_SIZE = 4096;
const REGISTER_SIZE = 16;
const STACK_SIZE = 16;
const KEYPAD_SIZE = constant.KEYPAD_SIZE;
const DISPLAY_HEIGHT = constant.INTERNAL_DISPLAY_HEIGHT;
const DISPLAY_WIDTH = constant.INTERNAL_DISPLAY_WIDTH;
const VRAM_SIZE = constant.VRAM_SIZE;

pub const Chip8 = struct {
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

    pub fn new() Chip8 {
        log.info("New Chip8 CPU initialized!", .{});

        return Chip8{
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
        };
    }

    pub fn load(self: *Chip8, path: []u8) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();

        const allocator = gpa.allocator();

        errdefer {
            log.warn("Failed to load file at path: {s}", .{path});
        }

        log.info("Trying to load file at path: {s}", .{path});

        const data = try cartridge.file_data(path, allocator);
        defer allocator.free(data);

        for (data, 0..data.len) |value, index| {
            self.memory[index + 512] = value;
        }
    }

    pub fn emulate_cycle(self: *Chip8) void {
        self.should_draw = false;

        self.fetch_opcode();
        self.execute_opcode();

        self.decrease_delay_timer();
        self.check_sound_timer();
    }

    fn fetch_opcode(self: *Chip8) void {
        const lhs: u16 = @intCast(self.memory[self.program_counter]);
        const rhs: u16 = @intCast(self.memory[self.program_counter + 1]);

        self.opcode = (lhs << 8) | rhs;
    }

    fn decrease_delay_timer(self: *Chip8) void {
        if (self.delay_timer > 0) {
            self.delay_timer -= 1;
        }
    }

    fn check_sound_timer(self: *Chip8) void {
        if (self.sound_timer > 0) {
            if (self.sound_timer == 1) {
                log.info("Beep!", .{});
            }

            self.sound_timer -= 1;
        }
    }

    fn decoded_opcode(self: Chip8) u16 {
        return self.opcode & 0xF000;
    }

    fn execute_opcode(self: *Chip8) void {
        switch (self.decoded_opcode()) {
            0x0000 => {
                const additional_value = self.opcode & 0x000F;
                switch (additional_value) {
                    0x0000 => opcode.op_00e0(self),
                    0x000E => opcode.op_00ee(self),
                    else => self.unknown_opcode(),
                }
            },
            0x1000 => opcode.op_1nnn(self),
            0x2000 => opcode.op_2nnn(self),
            0x3000 => opcode.op_3xnn(self),
            0x4000 => opcode.op_4xnn(self),
            0x5000 => opcode.op_5xy0(self),
            0x6000 => opcode.op_6xnn(self),
            0x7000 => opcode.op_7xnn(self),
            0x8000 => {
                const additional_value = self.opcode & 0x000F;
                switch (additional_value) {
                    0x0000 => opcode.op_8xy0(self),
                    0x0001 => opcode.op_8xy1(self),
                    0x0002 => opcode.op_8xy2(self),
                    0x0003 => opcode.op_8xy3(self),
                    0x0004 => opcode.op_8xy4(self),
                    0x0005 => opcode.op_8xy5(self),
                    0x0006 => opcode.op_8xy6(self),
                    0x0007 => opcode.op_8xy7(self),
                    0x000E => opcode.op_8xye(self),
                    else => self.unknown_opcode(),
                }
            },
            0x9000 => opcode.op_9xy0(self),
            0xA000 => opcode.op_annn(self),
            0xB000 => opcode.op_bnnn(self),
            0xC000 => opcode.op_cxnn(self),
            0xD000 => opcode.op_dxyn(self),
            0xE000 => {
                const additional_value = self.opcode & 0x00FF;
                switch (additional_value) {
                    0x009E => opcode.op_ex9e(self),
                    0x00A1 => opcode.op_exa1(self),
                    else => self.unknown_opcode(),
                }
            },
            0xF000 => {
                const additional_value = self.opcode & 0x00FF;
                switch (additional_value) {
                    0x0007 => opcode.op_fx07(self),
                    0x000A => opcode.op_fx0a(self),
                    0x0015 => opcode.op_fx15(self),
                    0x0018 => opcode.op_fx18(self),
                    0x001E => opcode.op_fx1e(self),
                    0x0029 => opcode.op_fx29(self),
                    0x0033 => opcode.op_fx33(self),
                    0x0055 => opcode.op_fx55(self),
                    0x0065 => opcode.op_fx65(self),
                    else => self.unknown_opcode(),
                }
            },
            else => self.unknown_opcode(),
        }
    }

    fn unknown_opcode(self: *Chip8) void {
        log.warn("Unknown opcode: 0x{X}!", .{self.opcode});
        self.program_counter += 2;
    }
};
