const std = @import("std");
const Chip8 = @import("chip8.zig").Chip8;

pub fn op_00e0(cpu: *Chip8) void {
    cpu.should_draw = true;

    cpu.vram = std.mem.zeroes([cpu.vram.len]u1);

    next(cpu);
}

pub fn op_00ee(cpu: *Chip8) void {
    cpu.stack_pointer -= 1;
    cpu.program_counter = cpu.stack[cpu.stack_pointer];
    next(cpu);
}

pub fn op_1nnn(cpu: *Chip8) void {
    cpu.program_counter = nnn_value(cpu);
}

pub fn op_2nnn(cpu: *Chip8) void {
    cpu.stack[cpu.stack_pointer] = cpu.program_counter;
    cpu.stack_pointer += 1;
    cpu.program_counter = nnn_value(cpu);
}

pub fn op_3xnn(cpu: *Chip8) void {
    const vx = vx_value(cpu);
    const nn = nn_value(cpu);

    if (vx == nn) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op_4xnn(cpu: *Chip8) void {
    const vx = vx_value(cpu);
    const nn = nn_value(cpu);

    if (vx != nn) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op_5xy0(cpu: *Chip8) void {
    const vx = vx_value(cpu);
    const vy = vy_value(cpu);

    if (vx == vy) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op_6xnn(cpu: *Chip8) void {
    const x = x_value(cpu);
    const nn: u8 = nn_value(cpu);
    cpu.registers[x] = nn;

    next(cpu);
}

pub fn op_7xnn(cpu: *Chip8) void {
    const x = x_value(cpu);
    const nn = nn_value(cpu);
    cpu.registers[x] +%= nn;

    next(cpu);
}

pub fn op_8xy0(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vy = vy_value(cpu);
    cpu.registers[x] = vy;

    next(cpu);
}

pub fn op_8xy1(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vy = vy_value(cpu);
    cpu.registers[x] |= vy;
    cpu.registers[0xF] = 0;

    next(cpu);
}

pub fn op_8xy2(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vy = vy_value(cpu);
    cpu.registers[x] &= vy;
    cpu.registers[0xF] = 0;

    next(cpu);
}

pub fn op_8xy3(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vy = vy_value(cpu);
    cpu.registers[x] ^= vy;
    cpu.registers[0xF] = 0;

    next(cpu);
}

pub fn op_8xy4(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vx = vx_value(cpu);
    const vy = vy_value(cpu);
    const sum = @addWithOverflow(vx, vy);

    cpu.registers[x] = sum[0];

    if (sum[1] != 0) {
        cpu.registers[0xF] = 1;
    } else {
        cpu.registers[0xF] = 0;
    }

    next(cpu);
}

pub fn op_8xy5(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vx = vx_value(cpu);
    const vy = vy_value(cpu);
    const difference = @subWithOverflow(vx, vy);

    cpu.registers[x] = difference[0];

    if (difference[1] != 0) {
        cpu.registers[0xF] = 0;
    } else {
        cpu.registers[0xF] = 1;
    }

    next(cpu);
}

pub fn op_8xy6(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vy = vy_value(cpu);

    cpu.registers[x] = vy;
    cpu.registers[x] >>= 1;
    cpu.registers[0xF] = vy & 0x1;

    next(cpu);
}

pub fn op_8xy7(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vx = vx_value(cpu);
    const vy = vy_value(cpu);
    const difference = @subWithOverflow(vy, vx);

    cpu.registers[x] = difference[0];

    if (difference[1] != 0) {
        cpu.registers[0xF] = 0;
    } else {
        cpu.registers[0xF] = 1;
    }

    next(cpu);
}

pub fn op_8xye(cpu: *Chip8) void {
    const x = x_value(cpu);
    const vy = vy_value(cpu);

    cpu.registers[x] = vy;
    cpu.registers[x] <<= 1;

    cpu.registers[0xF] = vy >> 7;

    next(cpu);
}

pub fn op_9xy0(cpu: *Chip8) void {
    const vx = vx_value(cpu);
    const vy = vy_value(cpu);

    if (vx != vy) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op_annn(cpu: *Chip8) void {
    cpu.index_register = nnn_value(cpu);
    next(cpu);
}

pub fn op_bnnn(cpu: *Chip8) void {
    const nnn: u16 = nnn_value(cpu);
    cpu.program_counter = nnn + cpu.registers[0];
}

pub fn op_cxnn(cpu: *Chip8) void {
    const nn = nn_value(cpu);
    const x = x_value(cpu);
    cpu.registers[x] = random_number() & nn;

    next(cpu);
}

pub fn op_dxyn(cpu: *Chip8) void {
    const vx: u16 = @intCast(vx_value(cpu) % 64);
    const vy: u16 = @intCast(vy_value(cpu) % 32);

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
                const index = (x + (y * 64)) % 2048;

                if (cpu.vram[index] == 1) {
                    cpu.registers[0xF] = 1;
                }
                cpu.vram[index] ^= 1;

                if (x == 64) {
                    break :width_loop;
                }
            }
        }

        if (y == 32) {
            break :height_loop;
        }
    }

    cpu.should_draw = true;
    next(cpu);
}

pub fn op_ex9e(cpu: *Chip8) void {
    const vx = vx_value(cpu);
    const key = cpu.keypad[vx];

    if (key != 0) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op_exa1(cpu: *Chip8) void {
    const vx = vx_value(cpu);
    const key = cpu.keypad[vx];

    if (key == 0) {
        skip(cpu);
    } else {
        next(cpu);
    }
}

pub fn op_fx07(cpu: *Chip8) void {
    const x = x_value(cpu);
    cpu.registers[x] = cpu.delay_timer;

    next(cpu);
}

pub fn op_fx0a(cpu: *Chip8) void {
    var was_key_pressed = false;
    const x = x_value(cpu);

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

pub fn op_fx15(cpu: *Chip8) void {
    cpu.delay_timer = vx_value(cpu);

    next(cpu);
}

pub fn op_fx18(cpu: *Chip8) void {
    cpu.sound_timer = vx_value(cpu);

    next(cpu);
}

pub fn op_fx1e(cpu: *Chip8) void {
    const vx_cast: u16 = @intCast(vx_value(cpu));
    const sum = cpu.index_register + vx_cast;

    if (sum > 0xFFF) {
        cpu.registers[0xF] = 1;
    } else {
        cpu.registers[0xF] = 0;
    }

    cpu.index_register = sum;

    next(cpu);
}

pub fn op_fx29(cpu: *Chip8) void {
    const vx_cast: u16 = @intCast(vx_value(cpu));
    cpu.index_register = vx_cast * 0x5;

    next(cpu);
}

pub fn op_fx33(cpu: *Chip8) void {
    const vx = vx_value(cpu);
    const index = cpu.index_register;

    cpu.memory[index] = vx / 100;
    cpu.memory[index + 1] = (vx / 10) % 10;
    cpu.memory[index + 2] = (vx % 100) % 10;

    next(cpu);
}

pub fn op_fx55(cpu: *Chip8) void {
    const x = x_value(cpu);
    var index: u16 = 0;

    while (index <= x) : (index += 1) {
        cpu.memory[cpu.index_register + index] = cpu.registers[index];
    }

    cpu.index_register += x + 1;

    next(cpu);
}

pub fn op_fx65(cpu: *Chip8) void {
    const x = x_value(cpu);
    var index: u16 = 0;

    while (index <= x) : (index += 1) {
        cpu.registers[index] = cpu.memory[cpu.index_register + index];
    }

    cpu.index_register += x + 1;

    next(cpu);
}

fn nn_value(cpu: *Chip8) u8 {
    return @intCast(cpu.opcode & 0x00FF);
}

fn nnn_value(cpu: *Chip8) u16 {
    return cpu.opcode & 0x0FFF;
}

fn x_value(cpu: *Chip8) u16 {
    return (cpu.opcode & 0x0F00) >> 8;
}

fn y_value(cpu: *Chip8) u16 {
    return (cpu.opcode & 0x00F0) >> 4;
}

fn vx_value(cpu: *Chip8) u8 {
    return cpu.registers[x_value(cpu)];
}

fn vy_value(cpu: *Chip8) u8 {
    return cpu.registers[y_value(cpu)];
}

fn next(cpu: *Chip8) void {
    cpu.program_counter += 2;
}

fn skip(cpu: *Chip8) void {
    cpu.program_counter += 4;
}

fn random_number() u8 {
    const timestamp = @as(u64, @bitCast(std.time.milliTimestamp()));
    var prng = std.Random.DefaultPrng.init(timestamp);

    const rand = prng.random();

    return rand.int(u8);
}
