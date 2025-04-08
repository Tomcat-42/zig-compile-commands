const std = @import("std");
const CompileCommands = @import("compile_commands");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const flags: []const []const u8 = &.{ "-gen-cdb-fragment-path", "cdb" };

    const example_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const example = b.addExecutable(.{
        .name = "example",
        .root_module = example_mod,
    });
    example.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{"example.c"},
        .flags = flags,
    });

    const cc_step = b.step("cc", "Generate Compile Commands Database");
    const gen_file_step = try CompileCommands.createStep(b, "cdb", "compile_commands.json");
    gen_file_step.dependOn(&example.step);
    cc_step.dependOn(gen_file_step);
}
