// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

//! An example of parsing CSS color string. The input is the first positional
//! argument or the standard input.

const std = @import("std");

const csscolorparser = @import("csscolorparser");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const input = if (args.len < 2)
        (try std.fs.File.stdin().deprecatedReader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))).?
    else
        try allocator.dupe(u8, args[1]);
    defer allocator.free(input);

    const color = try csscolorparser.Color(f64).parse(input);

    const stdout = std.fs.File.stdout().deprecatedWriter();
    if (color.name()) |name|
        try stdout.print("Name: {s}\n", .{name});
    {
        var buf: [9]u8 = undefined;
        const hex = try color.toHexString(&buf);
        try stdout.print("Hex: {s}\n", .{hex});
    }
    {
        const r, const g, const b, const a = color.toRgba8();
        const ap = (@as(f64, @floatFromInt(a)) / std.math.maxInt(u8)) * 100;
        try stdout.print("RGB: rgb({d} {d} {d} / {d:.1}%)\n", .{ r, g, b, ap });
    }
    {
        const h, const s, const l, const a = color.toHsl();
        const sp, const lp, const ap = .{ s * 100, l * 100, a * 100 };
        try stdout.print("HSL: hsl({d:.0}deg {d:.1}% {d:.1}% / {d:.1}%)\n", .{ h, sp, lp, ap });
    }
    {
        const h, const w, const b, const a = color.toHwb();
        const wp, const bp, const ap = .{ w * 100, b * 100, a * 100 };
        try stdout.print("HWB: hwb({d:.0}deg {d:.1}% {d:.1}% / {d:.1}%)\n", .{ h, wp, bp, ap });
    }
    {
        const l, const a, const b, const alpha = color.toOklab();
        const lp, const alpha_percentage = .{ l * 100, alpha * 100 };
        try stdout.print(
            "Oklab: oklab({d:.1}% {d:.3} {d:.3} / {d:.1}%)\n",
            .{ lp, a, b, alpha_percentage },
        );
    }
}
