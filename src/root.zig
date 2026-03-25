const std = @import("std");
const lightmix = @import("lightmix");
const lightmix_synths = @import("lightmix_synths");
const lightmix_filters = @import("lightmix_filters");

const Splitter = @import("./splitter.zig");
const SamplingType = f64;
const sample_rate = 44100;
const channels = 1;

pub fn gen(allocator: std.mem.Allocator) anyerror!lightmix.Wave(SamplingType) {
    // A number of samples per beat
    const spb = samples_per_beat(120, sample_rate);

    var waves: [16]?lightmix.Wave(SamplingType) = undefined;
    for (waves, 0..) |_, i| {
        if (i % 4 == 0 or i % 4 == 1) {
            var w: lightmix.Wave(SamplingType) = try lightmix_synths.Basic.Sine.gen(SamplingType, .{
                .allocator = allocator,
                .amplitude = 1.0,
                .frequency = 220.0,
                .length = 440.0,
                .sample_rate = sample_rate,
                .channels = channels,
            });
            try w.filter_with(lightmix_filters.volume.DecayArgs, lightmix_filters.volume.decay, .{});

            waves[i] = w;
        } else {
            waves[i] = null;
        }
    }
    defer for (waves) |wave| {
        if (wave != null) {
            wave.?.deinit();
        }
    };

    const result: lightmix.Wave(f64) = try Splitter.gen(SamplingType, .{
        .allocator = allocator,
        .amplitude = 1.0,
        .length = spb * 8,
        .takes = 16,
        .waves = &waves,
        .sample_rate = sample_rate,
        .channels = channels,
    });
    return result;
}

/// Returns a number of samples per beat
pub fn samples_per_beat(
    /// BPM
    bpm: usize,
    /// Sample rate
    spl: u32,
) usize {
    return @intFromFloat(@as(f32, @floatFromInt(60)) / @as(f32, @floatFromInt(bpm)) * @as(f32, @floatFromInt(spl)));
}
