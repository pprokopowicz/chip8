const std = @import("std");
const Module = std.Build.Module;
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const Compile = std.Build.Step.Compile;

const BuildError = error{
    UnavailablePlatform,
};

const constant_name = "constant";
const cpu_core_name = "cpu-core";
const cartridge_name = "cartridge";
const display_name = "display";
const input_event_name = "input-event";
const keypad_name = "keypad";
const socket_name = "socket";
const audio_name = "audio";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const constant = constant_module(b, target, optimize);
    const cpu_core = cpu_core_module(b, target, optimize);
    const cartridge = cartridge_module(b, target, optimize);
    const display = display_module(b, target, optimize);
    const input_event = input_event_module(b, target, optimize);
    const keypad = keypad_module(b, target, optimize);
    const socket = socket_module(b, target, optimize);
    const audio = audio_module(b, target, optimize);
    const exe = executable_compile(b, target, optimize);

    const link_modules = [_]*Module{ display, keypad, input_event, audio };
    try link_sdl(&link_modules, exe);

    cpu_core.addImport(constant_name, constant);
    cpu_core.addImport(cartridge_name, cartridge);
    display.addImport(constant_name, constant);
    keypad.addImport(constant_name, constant);
    exe.root_module.addImport(constant_name, constant);
    exe.root_module.addImport(cpu_core_name, cpu_core);
    exe.root_module.addImport(display_name, display);
    exe.root_module.addImport(input_event_name, input_event);
    exe.root_module.addImport(keypad_name, keypad);
    exe.root_module.addImport(socket_name, socket);
    exe.root_module.addImport(audio_name, audio);

    b.installArtifact(exe);

    add_run_step(b, exe);
}

fn constant_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(constant_name, .{
        .root_source_file = b.path("src/constant/constant.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn cpu_core_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(cpu_core_name, .{
        .root_source_file = b.path("src/cpu-core/chip8.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn cartridge_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(cartridge_name, .{
        .root_source_file = b.path("src/cartridge/cartridge.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn display_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(display_name, .{
        .root_source_file = b.path("src/display/display.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn input_event_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(input_event_name, .{
        .root_source_file = b.path("src/input-event/parse_event.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn keypad_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(keypad_name, .{
        .root_source_file = b.path("src/keypad/keypad.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn socket_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(socket_name, .{
        .root_source_file = b.path("src/socket/socket.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn audio_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    return b.addModule(audio_name, .{
        .root_source_file = b.path("src/audio/audio.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn executable_compile(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Compile {
    return b.addExecutable(.{
        .name = "chip8",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn link_sdl(modules: []const *Module, exe: *Compile) !void {
    for (modules) |module| {
        module.linkSystemLibrary("SDL3", .{ .needed = true });
    }
    exe.linkLibC();
}

fn add_run_step(b: *std.Build, exe: *Compile) void {
    const run_exe = b.addRunArtifact(exe);

    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
