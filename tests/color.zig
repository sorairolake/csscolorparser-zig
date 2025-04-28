// SPDX-FileCopyrightText: 2020 Nor Khasyatillah
// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

const testing = @import("std").testing;

const Color = @import("csscolorparser").Color;

test "basic" {
    var buf: [9]u8 = undefined;
    {
        const color = Color(f64).init(1.0, 0.0, 0.0, 1.0);
        try testing.expectEqualSlices(
            f64,
            &[4]f64{ 1.0, 0.0, 0.0, 1.0 },
            &[4]f64{ color.red, color.green, color.blue, color.alpha },
        );
        try testing.expectEqualSlices(u8, &[4]u8{ 255, 0, 0, 255 }, &color.toRgba8());
        const hex = try color.toHexString(&buf);
        try testing.expectEqualStrings("#ff0000", hex);
        try testing.expectEqualSlices(f64, &[4]f64{ 0.0, 1.0, 0.5, 1.0 }, &color.toHsl());
        try testing.expectEqualSlices(f64, &[4]f64{ 0.0, 0.0, 0.0, 1.0 }, &color.toHwb());
        try testing.expectEqualSlices(f64, &[4]f64{ 1.0, 0.0, 0.0, 1.0 }, &color.toLinearRgb());
    }

    {
        const color = Color(f64).init(1.0, 0.0, 0.0, 0.5);
        try testing.expectEqualSlices(u8, &[4]u8{ 255, 0, 0, 128 }, &color.toRgba8());
        const hex = try color.toHexString(&buf);
        try testing.expectEqualStrings("#ff000080", hex);
    }

    {
        const color = Color(f64).init(0.0, 1.0, 0.0, 1.0);
        try testing.expectEqualSlices(f64, &[4]f64{ 120.0, 1.0, 0.5, 1.0 }, &color.toHsl());
        try testing.expectEqualSlices(f64, &[4]f64{ 120.0, 0.0, 0.0, 1.0 }, &color.toHwb());
    }

    {
        const color = Color(f64).init(0.0, 0.0, 1.0, 1.0);
        try testing.expectEqualSlices(f64, &[4]f64{ 240.0, 1.0, 0.5, 1.0 }, &color.toHsl());
        try testing.expectEqualSlices(f64, &[4]f64{ 240.0, 0.0, 0.0, 1.0 }, &color.toHwb());
    }

    {
        const color = Color(f64).init(0.0, 0.0, 0.6, 1.0);
        try testing.expectEqualSlices(f64, &[4]f64{ 240.0, 1.0, 0.3, 1.0 }, &color.toHsl());
        try testing.expectEqualSlices(f64, &[4]f64{ 240.0, 0.0, 0.4, 1.0 }, &color.toHwb());
    }

    {
        const color = Color(f64).init(0.5, 0.5, 0.5, 1.0);
        try testing.expectEqualSlices(f64, &[4]f64{ 0.0, 0.0, 0.5, 1.0 }, &color.toHsl());
        try testing.expectEqualSlices(f64, &[4]f64{ 0.0, 0.5, 0.5, 1.0 }, &color.toHwb());
    }

    {
        const color = Color(f64){};
        try testing.expectEqualSlices(u8, &[4]u8{ 0, 0, 0, 255 }, &color.toRgba8());
    }

    {
        const color = Color(f64){ .red = 1.23, .green = 0.5, .blue = -0.01, .alpha = 1.01 };
        try testing.expectEqualSlices(
            f64,
            &[4]f64{ 1.23, 0.5, -0.01, 1.01 },
            &[4]f64{ color.red, color.green, color.blue, color.alpha },
        );
    }

    {
        var color = Color(f64){ .red = 1.23, .green = 0.5, .blue = -0.01, .alpha = 1.01 };
        color.clamp();
        try testing.expectEqualSlices(
            f64,
            &[4]f64{ 1.0, 0.5, 0.0, 1.0 },
            &[4]f64{ color.red, color.green, color.blue, color.alpha },
        );
        try testing.expectEqualSlices(u8, &[4]u8{ 255, 128, 0, 255 }, &color.toRgba8());
    }
}

test "convert colors" {
    const colors = [_]Color(f64){
        Color(f64).init(1.0, 0.7, 0.1, 1.0),
        Color(f64).fromRgba8(255, 179, 26, 255),
        Color(f64).fromRgba8(10, 255, 125, 0),
        Color(f64).fromLinearRgb(0.1, 0.9, 1.0, 1.0),
        Color(f64).fromHwb(0.0, 0.0, 0.0, 1.0),
        Color(f64).fromHwb(320.0, 0.1, 0.3, 1.0),
        Color(f64).fromHsl(120.0, 0.3, 0.2, 1.0),
    };
    var buf: [9]u8 = undefined;
    for (colors) |col| {
        {
            const a, const b, const c, const d = col.toLinearRgb();
            const x = Color(f64).fromLinearRgb(a, b, c, d);
            const col_hex = try col.toHexString(&buf);
            const x_hex = try x.toHexString(&buf);
            try testing.expectEqualStrings(col_hex, x_hex);
        }

        {
            const a, const b, const c, const d = col.toOklab();
            const x = Color(f64).fromOklab(a, b, c, d);
            const col_hex = try col.toHexString(&buf);
            const x_hex = try x.toHexString(&buf);
            try testing.expectEqualStrings(col_hex, x_hex);
        }
    }

    const data = [_][]const u8{
        "#000000",
        "#ffffff",
        "#999999",
        "#7f7f7f",
        "#ff0000",
        "#fa8072",
        "#87ceeb",
        "#ff6347",
        "#ee82ee",
        "#9acd32",
        "#0aff7d",
        "#09ff7d",
        "#ffb31a",
        "#0aff7d",
        "#09ff7d",
        "#825dfa6d",
        "#abc5679b",
    };
    for (data) |s| {
        const col = try Color(f64).parse(s);
        const hex = try col.toHexString(&buf);
        try testing.expectEqualStrings(s, hex);

        {
            const a, const b, const c, const d = col.toRgba8();
            const x = Color(f64).fromRgba8(a, b, c, d);
            const x_hex = try x.toHexString(&buf);
            try testing.expectEqualStrings(s, x_hex);
        }

        {
            const a, const b, const c, const d = col.toHsl();
            const x = Color(f64).fromHsl(a, b, c, d);
            const x_hex = try x.toHexString(&buf);
            try testing.expectEqualStrings(s, x_hex);
        }

        {
            const a, const b, const c, const d = col.toHwb();
            const x = Color(f64).fromHwb(a, b, c, d);
            const x_hex = try x.toHexString(&buf);
            try testing.expectEqualStrings(s, x_hex);
        }

        {
            const a, const b, const c, const d = col.toLinearRgb();
            const x = Color(f64).fromLinearRgb(a, b, c, d);
            const x_hex = try x.toHexString(&buf);
            try testing.expectEqualStrings(s, x_hex);
        }

        {
            const a, const b, const c, const d = col.toOklab();
            const x = Color(f64).fromOklab(a, b, c, d);
            const x_hex = try x.toHexString(&buf);
            try testing.expectEqualStrings(s, x_hex);
        }
    }
}

test "red" {
    const data = [_]Color(f64){
        Color(f64).init(1.0, 0.0, 0.0, 1.0),
        Color(f64).fromRgba8(255, 0, 0, 255),
        Color(f64).fromLinearRgb(1.0, 0.0, 0.0, 1.0),
        Color(f64).fromHsl(360.0, 1.0, 0.5, 1.0),
        Color(f64).fromHwb(0.0, 0.0, 0.0, 1.0),
        Color(f64).fromOklab(
            0.627_915_193_996_980_9,
            0.224_903_230_866_107_1,
            0.125_802_870_124_518_02,
            1.0,
        ),
    };
    for (data) |c| {
        try testing.expectEqualSlices(u8, &[4]u8{ 255, 0, 0, 255 }, &c.toRgba8());
    }
}
