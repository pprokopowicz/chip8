const std = @import("std");
const Module = std.Build.Module;
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const Compile = std.Build.Step.Compile;

const constant_name = "constant";
const constant_path = "src/constant/constant.zig";

const cpu_core_name = "cpu-core";
const cpu_core_path = "src/cpu-core/chip8.zig";

const cartridge_name = "cartridge";
const cartridge_path = "src/cartridge/cartridge.zig";

const display_name = "display";
const display_path = "src/display/display.zig";

const utility_name = "utility";
const utility_path = "src/utility/root.zig";

const keypad_name = "keypad";
const keypad_path = "src/keypad/keypad.zig";

const audio_name = "audio";
const audio_path = "src/audio/audio.zig";

const sdl_name = "sdl";
const sdl3_library_name = "SDL3";
const sdl_path = "src/sdl/sdl.zig";
const sdl_header_path = "src/sdl3.h";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const constant = create_module(b, target, optimize, constant_name, constant_path);
    const cpu_core = create_module(b, target, optimize, cpu_core_name, cpu_core_path);
    const cartridge = create_module(b, target, optimize, cartridge_name, cartridge_path);
    const display = create_module(b, target, optimize, display_name, display_path);
    const utility = create_module(b, target, optimize, utility_name, utility_path);
    const keypad = create_module(b, target, optimize, keypad_name, keypad_path);
    const audio = create_module(b, target, optimize, audio_name, audio_path);
    const sdl = sdl_module(b, target, optimize);

    const exe = executable_compile(b, target, optimize);

    cpu_core.addImport(constant_name, constant);
    cpu_core.addImport(cartridge_name, cartridge);
    audio.addImport(sdl_name, sdl);
    display.addImport(constant_name, constant);
    display.addImport(sdl_name, sdl);
    keypad.addImport(sdl_name, sdl);
    keypad.addImport(constant_name, constant);
    utility.addImport(sdl_name, sdl);

    exe.root_module.addImport(constant_name, constant);
    exe.root_module.addImport(cpu_core_name, cpu_core);
    exe.root_module.addImport(display_name, display);
    exe.root_module.addImport(utility_name, utility);
    exe.root_module.addImport(keypad_name, keypad);
    exe.root_module.addImport(audio_name, audio);

    b.installArtifact(exe);

    add_run_step(b, exe);
}

fn create_module(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    name: []const u8,
    root_source_file: []const u8,
) *Module {
    return b.addModule(name, .{
        .root_source_file = b.path(root_source_file),
        .target = target,
        .optimize = optimize,
    });
}

fn sdl_module(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Module {
    const sdl3 = b.addTranslateC(.{
        .root_source_file = b.path(sdl_header_path),
        .target = target,
        .optimize = optimize,
    });
    sdl3.linkSystemLibrary(sdl3_library_name, .{ .needed = true });

    return b.addModule(sdl_name, .{
        .root_source_file = b.path(sdl_path),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = sdl3_library_name,
                .module = sdl3.createModule(),
            },
        },
    });
}

fn executable_compile(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Compile {
    return b.addExecutable(.{
        .name = "chip8",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
}

fn add_run_step(b: *std.Build, exe: *Compile) void {
    const run_exe = b.addRunArtifact(exe);

    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
