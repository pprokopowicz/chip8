const std = @import("std");
const Module = std.Build.Module;
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const Compile = std.Build.Step.Compile;

const BuildError = error{
    UnavailablePlatform,
};

const cpu_core_name = "cpu-core";
const cartridge_name = "cartridge";
const display_name = "display";

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cpu_core = cpu_core_module(b, target, optimize);
    const cartridge = cartridge_module(b, target, optimize);
    const display = display_module(b, target, optimize);
    const keypad = keypad_module(b, target, optimize);
    const exe = executable_compile(b, target, optimize);

    const link_modules = [_]*Module{display};
    try link_library(b, target, &link_modules, exe);

    cpu_core.addImport(cartridge_name, cartridge);
    exe.root_module.addImport(cpu_core_name, cpu_core);
    exe.root_module.addImport(display_name, display);

    b.installArtifact(exe);

    add_run_step(b, exe);
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


fn executable_compile(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Compile {
    return b.addExecutable(.{
        .name = "chip8",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn link_library(b: *std.Build, target: ResolvedTarget, modules: []const *Module, exe: *Compile) !void {
    switch (target.result.os.tag) {
        .macos => {
            for (modules) |module| {
                module.addFrameworkPath(b.path("lib/SDL3/macOS"));
                module.addLibraryPath(b.path("lib/SDL3/macOS"));
                module.linkFramework("SDL3", .{ .needed = true });
            }
        },
        .linux => {
            for (modules) |module| {
                module.linkSystemLibrary("SDL3", .{ .needed = true });
            }
            exe.linkLibC();
        },
        else => return BuildError.UnavailablePlatform,
    }
}

fn add_run_step(b: *std.Build, exe: *Compile) void {
    const run_exe = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
