const std = @import("std");
const constant = @import("constant");
const Chip8 = @import("chip8.zig").Chip8;

const DISPLAY_HEIGHT = constant.INTERNAL_DISPLAY_HEIGHT;
const DISPLAY_WIDTH = constant.INTERNAL_DISPLAY_WIDTH;
const VRAM_SIZE = constant.VRAM_SIZE;

pub fn op00e0(cpu: *Chip8) void {
    cpu.should_draw = true;

    cpu.vram = std.mem.zeroes([cpu.vram.len]u1);

    next(cpu);
}

pub fn op00ee(cpu: *Chip8) void {
    cpu.stack_pointer -= 1;
    cpu.program_counter = cpu.stack[cpu.stack_pointer];
    next(cpu);
}

pub fn op1nnn(cpu: *Chip8) void {
    cpu.program_counter = nnnValue(cpu);
}

pub fn op2nnn(cpu: *Chip8) void {
    cpu.stack[cpu.stack_pointer] = cpu.program_counter;
    cpu.stack_pointer += 1;
    cpu.program_counter = nnnValue(cpu);
}

pub fn op3xnn(cpu: *Chip8) void {
    const vx = vxValue(cpu);
    const nn = nnValue(cpu);

    if (vx == nn) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op4xnn(cpu: *Chip8) void {
    const vx = vxValue(cpu);
    const nn = nnValue(cpu);

    if (vx != nn) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op5xy0(cpu: *Chip8) void {
    const vx = vxValue(cpu);
    const vy = vyValue(cpu);

    if (vx == vy) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op6xnn(cpu: *Chip8) void {
    const x = xValue(cpu);
    const nn: u8 = nnValue(cpu);
    cpu.registers[x] = nn;

    next(cpu);
}

pub fn op7xnn(cpu: *Chip8) void {
    const x = xValue(cpu);
    const nn = nnValue(cpu);
    cpu.registers[x] +%= nn;

    next(cpu);
}

pub fn op8xy0(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vy = vyValue(cpu);
    cpu.registers[x] = vy;

    next(cpu);
}

pub fn op8xy1(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vy = vyValue(cpu);
    cpu.registers[x] |= vy;
    cpu.registers[0xF] = 0;

    next(cpu);
}

pub fn op8xy2(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vy = vyValue(cpu);
    cpu.registers[x] &= vy;
    cpu.registers[0xF] = 0;

    next(cpu);
}

pub fn op8xy3(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vy = vyValue(cpu);
    cpu.registers[x] ^= vy;
    cpu.registers[0xF] = 0;

    next(cpu);
}

pub fn op8xy4(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vx = vxValue(cpu);
    const vy = vyValue(cpu);
    const sum = @addWithOverflow(vx, vy);

    cpu.registers[x] = sum[0];

    if (sum[1] != 0) {
        cpu.registers[0xF] = 1;
    } else {
        cpu.registers[0xF] = 0;
    }

    next(cpu);
}

pub fn op8xy5(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vx = vxValue(cpu);
    const vy = vyValue(cpu);
    const difference = @subWithOverflow(vx, vy);

    cpu.registers[x] = difference[0];

    if (difference[1] != 0) {
        cpu.registers[0xF] = 0;
    } else {
        cpu.registers[0xF] = 1;
    }

    next(cpu);
}

pub fn op8xy6(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vy = vyValue(cpu);

    cpu.registers[x] = vy;
    cpu.registers[x] >>= 1;
    cpu.registers[0xF] = vy & 0x1;

    next(cpu);
}

pub fn op8xy7(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vx = vxValue(cpu);
    const vy = vyValue(cpu);
    const difference = @subWithOverflow(vy, vx);

    cpu.registers[x] = difference[0];

    if (difference[1] != 0) {
        cpu.registers[0xF] = 0;
    } else {
        cpu.registers[0xF] = 1;
    }

    next(cpu);
}

pub fn op8xye(cpu: *Chip8) void {
    const x = xValue(cpu);
    const vy = vyValue(cpu);

    cpu.registers[x] = vy;
    cpu.registers[x] <<= 1;

    cpu.registers[0xF] = vy >> 7;

    next(cpu);
}

pub fn op9xy0(cpu: *Chip8) void {
    const vx = vxValue(cpu);
    const vy = vyValue(cpu);

    if (vx != vy) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn opannn(cpu: *Chip8) void {
    cpu.index_register = nnnValue(cpu);
    next(cpu);
}

pub fn opbnnn(cpu: *Chip8) void {
    const nnn: u16 = nnnValue(cpu);
    cpu.program_counter = nnn + cpu.registers[0];
}

pub fn opcxnn(cpu: *Chip8) void {
    const nn = nnValue(cpu);
    const x = xValue(cpu);
    cpu.registers[x] = randomNumber(cpu.io) & nn;

    next(cpu);
}

pub fn opdxyn(cpu: *Chip8) void {
    const vx: u16 = @intCast(vxValue(cpu) % DISPLAY_WIDTH);
    const vy: u16 = @intCast(vyValue(cpu) % DISPLAY_HEIGHT);

    const height = cpu.opcode & 0x000F;
    var pixel: u8 = undefined;

    cpu.registers[0xF] = 0;

    var y_line: u16 = 0;

    height_loop: while (y_line < height) : (y_line += 1) {
        pixel = cpu.memory[cpu.index_register + y_line];

        const y = y_line + vy;

        const masks = [_]u8{ 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };

        width_loop: for (masks, 0..masks.len) |mask, x_line| {
            if ((pixel & mask) != 0) {
                const x = vx + x_line;
                const index = (x + (y * 64)) % VRAM_SIZE;

                if (cpu.vram[index] == 1) {
                    cpu.registers[0xF] = 1;
                }
                cpu.vram[index] ^= 1;

                if (x == DISPLAY_WIDTH) {
                    break :width_loop;
                }
            }
        }

        if (y == DISPLAY_HEIGHT) {
            break :height_loop;
        }
    }

    cpu.should_draw = true;
    next(cpu);
}

pub fn opex9e(cpu: *Chip8) void {
    const vx = vxValue(cpu);
    const key = cpu.keypad[vx];

    if (key != 0) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn opexa1(cpu: *Chip8) void {
    const vx = vxValue(cpu);
    const key = cpu.keypad[vx];

    if (key == 0) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn opfx07(cpu: *Chip8) void {
    const x = xValue(cpu);
    cpu.registers[x] = cpu.delay_timer;

    next(cpu);
}

pub fn opfx0a(cpu: *Chip8) void {
    var was_key_pressed = false;
    const x = xValue(cpu);

    for (cpu.keypad, 0..cpu.keypad.len) |value, index| {
        if (value != 0) {
            cpu.registers[x] = @intCast(index);
            was_key_pressed = true;
        }
    }

    if (!was_key_pressed) {
        return;
    }

    next(cpu);
}

pub fn opfx15(cpu: *Chip8) void {
    cpu.delay_timer = vxValue(cpu);

    next(cpu);
}

pub fn opfx18(cpu: *Chip8) void {
    cpu.sound_timer = vxValue(cpu);

    next(cpu);
}

pub fn opfx1e(cpu: *Chip8) void {
    const vx_cast: u16 = @intCast(vxValue(cpu));
    const sum = cpu.index_register + vx_cast;

    if (sum > 0xFFF) {
        cpu.registers[0xF] = 1;
    } else {
        cpu.registers[0xF] = 0;
    }

    cpu.index_register = sum;

    next(cpu);
}

pub fn opfx29(cpu: *Chip8) void {
    const vx_cast: u16 = @intCast(vxValue(cpu));
    cpu.index_register = vx_cast * 0x5;

    next(cpu);
}

pub fn opfx33(cpu: *Chip8) void {
    const vx = vxValue(cpu);
    const index = cpu.index_register;

    cpu.memory[index] = vx / 100;
    cpu.memory[index + 1] = (vx / 10) % 10;
    cpu.memory[index + 2] = (vx % 100) % 10;

    next(cpu);
}

pub fn opfx55(cpu: *Chip8) void {
    const x = xValue(cpu);
    var index: u16 = 0;

    while (index <= x) : (index += 1) {
        cpu.memory[cpu.index_register + index] = cpu.registers[index];
    }

    cpu.index_register += x + 1;

    next(cpu);
}

pub fn opfx65(cpu: *Chip8) void {
    const x = xValue(cpu);
    var index: u16 = 0;

    while (index <= x) : (index += 1) {
        cpu.registers[index] = cpu.memory[cpu.index_register + index];
    }

    cpu.index_register += x + 1;

    next(cpu);
}

fn nnValue(cpu: *Chip8) u8 {
    return @intCast(cpu.opcode & 0x00FF);
}

fn nnnValue(cpu: *Chip8) u16 {
    return cpu.opcode & 0x0FFF;
}

fn xValue(cpu: *Chip8) u16 {
    return (cpu.opcode & 0x0F00) >> 8;
}

fn yValue(cpu: *Chip8) u16 {
    return (cpu.opcode & 0x00F0) >> 4;
}

fn vxValue(cpu: *Chip8) u8 {
    return cpu.registers[xValue(cpu)];
}

fn vyValue(cpu: *Chip8) u8 {
    return cpu.registers[yValue(cpu)];
}

fn next(cpu: *Chip8) void {
    cpu.program_counter += 2;
}

fn skip(cpu: *Chip8) void {
    cpu.program_counter += 4;
}

fn randomNumber(io: std.Io) u8 {
    const test123 = std.Io.Clock.real.now(io).toMilliseconds();
    const timestamp = @as(u64, @bitCast(test123));
    var prng = std.Random.DefaultPrng.init(timestamp);

    const rand = prng.random();

    return rand.int(u8);
}
