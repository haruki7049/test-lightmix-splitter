const std = @import("std");
const lightmix = @import("lightmix");

pub fn gen(comptime T: type, arguments: Arguments(T)) anyerror!lightmix.Wave(T) {
    var composer = lightmix.Composer(T).init(arguments.allocator, .{
        .channels = arguments.channels,
        .sample_rate = arguments.sample_rate,
    });
    defer composer.deinit();

    // Get a interval for each Wave
    const interval: usize = arguments.length / arguments.takes;

    // Adds each wave to the `var composer`
    var intervals: usize = 0;
    for (arguments.waves) |wave| {
        try composer.append(.{ .wave = wave, .start_point = intervals });
        intervals += interval;
    }

    const result: lightmix.Wave(T) = try composer.finalize(.{});
    return result;
}

pub fn Arguments(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        amplitude: f32,
        length: usize,
        takes: usize,
        waves: []const lightmix.Wave(T),
        sample_rate: u32,
        channels: u16,
    };
}
