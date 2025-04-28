// SPDX-FileCopyrightText: 2020 Nor Khasyatillah
// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

const std = @import("std");

const csscolorparser = @import("csscolorparser");

const ascii = std.ascii;
const math = std.math;
const testing = std.testing;

const Color = csscolorparser.Color;

test "named_colors" {
    {
        const skip_list = [_][]const u8{ "aqua", "cyan", "fuchsia", "magenta" };

        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            outer: for (csscolorparser.named_colors.keys(), csscolorparser.named_colors.values()) |name, rgb| {
                const c1 = try Color(ft).parse(name);
                try testing.expectEqual(rgb, c1.toRgba8()[0..3].*);

                for (skip_list) |sl| {
                    if (ascii.eqlIgnoreCase(name, sl)) continue :outer;
                }
                if ((ascii.indexOfIgnoreCase(name, "gray") != null) or (ascii.indexOfIgnoreCase(name, "grey") != null))
                    continue;
                try testing.expectEqualStrings(name, c1.name().?);

                const r, const g, const b = rgb;
                const c2 = Color(ft).fromRgba8(r, g, b, math.maxInt(u8));
                try testing.expectEqualStrings(name, c2.name().?);
            }
        }
    }

    {
        const test_data = [_][2][]const u8{
            .{ "aliceblue", "#f0f8ff" },
            .{ "bisque", "#ffe4c4" },
            .{ "black", "#000000" },
            .{ "chartreuse", "#7fff00" },
            .{ "coral", "#ff7f50" },
            .{ "crimson", "#dc143c" },
            .{ "dodgerblue", "#1e90ff" },
            .{ "firebrick", "#b22222" },
            .{ "gold", "#ffd700" },
            .{ "hotpink", "#ff69b4" },
            .{ "indigo", "#4b0082" },
            .{ "lavender", "#e6e6fa" },
            .{ "lime", "#00ff00" },
            .{ "plum", "#dda0dd" },
            .{ "red", "#ff0000" },
            .{ "salmon", "#fa8072" },
            .{ "skyblue", "#87ceeb" },
            .{ "tomato", "#ff6347" },
            .{ "violet", "#ee82ee" },
            .{ "yellowgreen", "#9acd32" },
        };

        var buf: [9]u8 = undefined;
        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            for (test_data) |td| {
                const c1 = try Color(ft).parse(td[0]);
                const hex = try c1.toHexString(&buf);
                try testing.expectEqualStrings(td[1], hex);

                const c2 = try Color(ft).parse(td[1]);
                try testing.expectEqualStrings(td[0], c2.name().?);
            }
        }
    }

    {
        const float_types = [_]type{ f16, f32, f64, f80, f128 };
        inline for (float_types) |ft| {
            const test_data = [_]Color(ft){
                Color(ft).init(0.7, 0.8, 0.9, 1.0),
                Color(ft).init(1.0, 0.5, 0.0, 1.0),
                Color(ft).fromRgba8(0, 50, 100, 255),
            };
            for (test_data) |c| {
                try testing.expectEqual(null, c.name());
            }
        }
    }
}
