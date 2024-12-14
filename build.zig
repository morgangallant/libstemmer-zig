const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libstemmer = buildLibStemmer(b, target, optimize);

    const module = b.addModule("libstemmer", .{ .root_source_file = b.path("src/root.zig") });
    libstemmer.linkAndAddInclude(module);

    const lib = b.addStaticLibrary(.{
        .name = "stemmer-zig",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    libstemmer.linkAndAddInclude(lib);
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    libstemmer.linkAndAddInclude(lib_unit_tests);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const LibStemmer = struct {
    compiled_lib: *std.Build.Step.Compile,
    include_path: std.Build.LazyPath,

    fn linkAndAddInclude(self: *const LibStemmer, step: anytype) void {
        step.linkLibrary(self.compiled_lib);
        step.addIncludePath(self.include_path);
    }
};

fn buildLibStemmer(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) LibStemmer {
    const dep = b.dependency("libstemmer", .{});
    const lib = b.addStaticLibrary(.{
        .name = "stemmer_c",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(dep.path("include"));
    lib.addCSourceFiles(.{
        .root = dep.path("runtime"),
        .files = &.{
            "api.c",
            "utilities.c",
        },
    });
    lib.addCSourceFiles(.{
        .root = dep.path("src_c"),
        .files = &.{
            "stem_ISO_8859_1_basque.c",
            "stem_ISO_8859_1_catalan.c",
            "stem_ISO_8859_1_danish.c",
            "stem_ISO_8859_1_dutch.c",
            "stem_ISO_8859_1_english.c",
            "stem_ISO_8859_1_finnish.c",
            "stem_ISO_8859_1_french.c",
            "stem_ISO_8859_1_german.c",
            "stem_ISO_8859_1_indonesian.c",
            "stem_ISO_8859_1_irish.c",
            "stem_ISO_8859_1_italian.c",
            "stem_ISO_8859_1_norwegian.c",
            "stem_ISO_8859_1_porter.c",
            "stem_ISO_8859_1_portuguese.c",
            "stem_ISO_8859_1_spanish.c",
            "stem_ISO_8859_1_swedish.c",
            "stem_ISO_8859_2_hungarian.c",
            "stem_ISO_8859_2_romanian.c",
            "stem_KOI8_R_russian.c",
            "stem_UTF_8_arabic.c",
            "stem_UTF_8_armenian.c",
            "stem_UTF_8_basque.c",
            "stem_UTF_8_catalan.c",
            "stem_UTF_8_danish.c",
            "stem_UTF_8_dutch.c",
            "stem_UTF_8_english.c",
            "stem_UTF_8_finnish.c",
            "stem_UTF_8_french.c",
            "stem_UTF_8_german.c",
            "stem_UTF_8_greek.c",
            "stem_UTF_8_hindi.c",
            "stem_UTF_8_hungarian.c",
            "stem_UTF_8_indonesian.c",
            "stem_UTF_8_irish.c",
            "stem_UTF_8_italian.c",
            "stem_UTF_8_lithuanian.c",
            "stem_UTF_8_nepali.c",
            "stem_UTF_8_norwegian.c",
            "stem_UTF_8_porter.c",
            "stem_UTF_8_portuguese.c",
            "stem_UTF_8_romanian.c",
            "stem_UTF_8_russian.c",
            "stem_UTF_8_serbian.c",
            "stem_UTF_8_spanish.c",
            "stem_UTF_8_swedish.c",
            "stem_UTF_8_tamil.c",
            "stem_UTF_8_turkish.c",
            "stem_UTF_8_yiddish.c",
        },
    });
    lib.addCSourceFile(.{
        .file = dep.path("libstemmer/libstemmer.c"),
    });
    return .{
        .compiled_lib = lib,
        .include_path = dep.path("include"),
    };
}
