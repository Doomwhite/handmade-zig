const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "handmade-zig",
        .root_source_file = b.path("src/win32_handmade.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Build options.
    const build_options = b.addOptions();
    build_options.addOption(bool, "timing", b.option(bool, "timing", "print timing info to debug output") orelse false);
    exe.root_module.addOptions("build_options", build_options);

    // Add the win32 API wrapper.
    const zigwin32 = b.dependency("zigwin32", .{}).module("zigwin32");
    exe.root_module.addImport("win32", zigwin32);

    b.installArtifact(exe);

    // Build the game library.
    const lib_handmade = b.addSharedLibrary(.{
        .name = "handmade",
        .root_source_file = b.path("src/handmade.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });

    b.installArtifact(lib_handmade);

    // Allow running from build command.
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
