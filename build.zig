const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cpu_core_name = "cpu-core";
    const cartridge_name = "cartridge";
    const display_name = "display";

    const cpu_core = b.addModule(cpu_core_name, .{
        .root_source_file = b.path("src/cpu-core/chip8.zig"),
        .target = target,
        .optimize = optimize,
    });

    const cartridge = b.addModule(cartridge_name, .{
        .root_source_file = b.path("src/cartridge/cartridge.zig"),
        .target = target,
        .optimize = optimize,
    });

    const display = b.addModule(display_name, .{
        .root_source_file = b.path("src/display/display.zig"),
        .target = target,
        .optimize = optimize,
    });

    display.addFrameworkPath(b.path("lib/SDL3/macOS"));
    display.addLibraryPath(b.path("lib/SDL3/macOS"));
    display.linkFramework("SDL3", .{ .needed = true });

    const exe = b.addExecutable(.{
        .name = "chip8",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    cpu_core.addImport(cartridge_name, cartridge);
    exe.root_module.addImport(cpu_core_name, cpu_core);
    exe.root_module.addImport(display_name, display);

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
