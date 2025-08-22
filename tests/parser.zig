// SPDX-FileCopyrightText: 2020 Nor Khasyatillah
// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

const std = @import("std");

const csscolorparser = @import("csscolorparser");

const meta = std.meta;
const testing = std.testing;

const Color = csscolorparser.Color;
const ParseColorError = csscolorparser.ParseColorError;

test "parser" {
    const test_data = [_]struct { []const u8, [4]u8 }{
        .{ "transparent", .{ 0, 0, 0, 0 } },
        .{ "#ff00ff64", .{ 255, 0, 255, 100 } },
        .{ "ff00ff64", .{ 255, 0, 255, 100 } },
        .{ "rgb(247,179,99)", .{ 247, 179, 99, 255 } },
        .{ "rgb(50% 50% 50%)", .{ 128, 128, 128, 255 } },
        .{ "rgb(247,179,99,0.37)", .{ 247, 179, 99, 94 } },
        .{ "hsl(270 0% 50%)", .{ 128, 128, 128, 255 } },
        .{ "hwb(0 50% 50%)", .{ 128, 128, 128, 255 } },
    };

    const float_types = [_]type{ f32, f64 };
    inline for (float_types) |ft| {
        for (test_data) |td| {
            const a = try Color(ft).parse(td[0]);
            try testing.expectEqual(td[1], a.toRgba8());
        }
    }
}

test "equal" {
    const test_data = [_][2][]const u8{
        .{ "transparent", "rgb(0,0,0,0%)" },
        .{ "#FF9900", "#f90" },
        .{ "#aabbccdd", "#ABCD" },
        .{ "#BAD455", "BAD455" },
        .{ "rgb(0 255 127 / 75%)", "rgb(0,255,127,0.75)" },
        .{ "hwb(180 0% 60%)", "hwb(180,0%,60%)" },
        .{ "hwb(290 30% 0%)", "hwb(290 0.3 0)" },
        .{ "hsl(180,50%,27%)", "hsl(180,0.5,0.27)" },
        .{ "rgb(255, 165, 0)", "hsl(38.824 100% 50%)" },
        .{ "#7654CD", "rgb(46.27% 32.94% 80.39%)" },
    };

    const float_types = [_]type{ f32, f64 };
    inline for (float_types) |ft| {
        for (test_data) |td| {
            const a = try Color(ft).parse(td[0]);
            const b = try Color(ft).parse(td[1]);
            try testing.expectEqual(a.toRgba8(), b.toRgba8());
        }
    }
}

test "black" {
    const data = [_][]const u8{
        "#000",
        "#000f",
        "#000000",
        "#000000ff",
        "000",
        "000f",
        "000000",
        "000000ff",
        "rgb(0,0,0)",
        "rgb(0% 0% 0%)",
        "rgb(0 0 0 100%)",
        "hsl(270,100%,0%)",
        "hwb(90 0% 100%)",
        "hwb(120deg 0% 100% 100%)",
    };

    const black = [4]u8{ 0, 0, 0, 255 };

    const float_types = [_]type{ f32, f64 };
    inline for (float_types) |ft| {
        for (data) |s| {
            const c = try Color(ft).parse(s);
            try testing.expectEqual(black, c.toRgba8());
        }
    }
}

test "red" {
    const data = [_][]const u8{
        "#f00",
        "#f00f",
        "#ff0000",
        "#ff0000ff",
        "f00",
        "f00f",
        "ff0000",
        "ff0000ff",
        "rgb(255,0,0)",
        "rgb(255 0 0)",
        "rgb(700, -99, 0)",
        "rgb(100% 0% 0%)",
        "rgb(200% -10% -100%)",
        "rgb(255 0 0 100%)",
        " RGB ( 255 , 0 , 0 ) ",
        "RGB( 255   0   0 )",
        "hsl(0,100%,50%)",
        "hsl(360 100% 50%)",
        "hwb(0 0% 0%)",
        "hwb(360deg 0% 0% 100%)",
        "oklab(0.62796, 0.22486, 0.12585)",
        "oklch(0.62796, 0.25768, 29.23388)",
    };

    const red = [4]u8{ 255, 0, 0, 255 };

    const float_types = [_]type{ f32, f64 };
    inline for (float_types) |ft| {
        for (data) |s| {
            const c = try Color(ft).parse(s);
            try testing.expectEqual(red, c.toRgba8());
        }
    }
}

test "lime" {
    const data = [_][]const u8{
        "#0f0",
        "#0f0f",
        "#00ff00",
        "#00ff00ff",
        "0f0",
        "0f0f",
        "00ff00",
        "00ff00ff",
        "rgb(0,255,0)",
        "rgb(0% 100% 0%)",
        "rgb(0 255 0 / 100%)",
        "rgba(0,255,0,1)",
        "hsl(120,100%,50%)",
        "hsl(120deg 100% 50%)",
        "hsl(-240 100% 50%)",
        "hsl(-240deg 100% 50%)",
        "hsl(0.3333turn 100% 50%)",
        "hsl(133.333grad 100% 50%)",
        "hsl(2.0944rad 100% 50%)",
        "hsla(120,100%,50%,100%)",
        "hwb(120 0% 0%)",
        "hwb(480deg 0% 0% / 100%)",
        "oklab(0.86644, -0.23389, 0.1795)",
        "oklch(0.86644, 0.29483, 142.49535)",
    };

    const lime = [4]u8{ 0, 255, 0, 255 };

    const float_types = [_]type{ f32, f64 };
    inline for (float_types) |ft| {
        for (data) |s| {
            const c = try Color(ft).parse(s);
            try testing.expectEqual(lime, c.toRgba8());
        }
    }
}

test "lime alpha" {
    const data = [_][]const u8{
        "#00ff0080",
        "00ff0080",
        "rgb(0,255,0,50%)",
        "rgb(0% 100% 0% / 0.5)",
        "rgba(0%,100%,0%,50%)",
        "hsl(120,100%,50%,0.5)",
        "hsl(120deg 100% 50% / 50%)",
        "hsla(120,100%,50%,0.5)",
        "hwb(120 0% 0% / 50%)",
    };

    const lime_alpha = [4]u8{ 0, 255, 0, 128 };

    const float_types = [_]type{ f32, f64 };
    inline for (float_types) |ft| {
        for (data) |s| {
            const c = try Color(ft).parse(s);
            try testing.expectEqual(lime_alpha, c.toRgba8());
        }
    }
}

test "invalid format" {
    {
        const test_data = [_][]const u8{
            "",
            "bloodred",
            "#78afzd",
            "#fffff",
            "rgb(255,0,0",
            "rgb(0,255,8s)",
            "rgb(100%,z9%,75%)",
            "rgb(255,0,0%)",
            "rgb(70%,30%,0)",
            "cmyk(1 0 0)",
            "rgba(0 0)",
            "hsl(90',100%,50%)",
            "hsl(360,70%,50%,90%,100%)",
            "hsl(deg 100% 50%)",
            "hsl(Xturn 100% 50%)",
            "hsl(Zgrad 100% 50%)",
            "hsl(180 1 x%)",
            "hsl(360,0%,0)",
            "hsla(360)",
            "hwb(Xrad,50%,50%)",
            "hwb(270 0% 0% 0% 0%)",
            "hwb(360,0,20%)",
            "hsv(120 100% 100% 1 50%)",
            "hsv(120 XXX 100%)",
            "hsv(120,100%,0.5)",
            "lab(100%,0)",
            "lab(100% 0 X)",
            "lch(100%,0)",
            "lch(100% 0 X)",
            "oklab(0,0)",
            "oklab(0,0,x,0)",
            "oklch(0,0,0,0,0)",
            "oklch(0,0,0,x)",
        };

        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            for (test_data) |s| {
                const c = Color(ft).parse(s);
                try testing.expect(meta.isError(c));
            }
        }
    }

    {
        const test_data = [_]struct { []const u8, ParseColorError }{
            .{ "#78afzd", ParseColorError.InvalidHex },
            .{ "rgb(255,0)", ParseColorError.InvalidRgb },
            .{ "hsl(0,100%,2o%)", ParseColorError.InvalidHsl },
            .{ "hsv(360)", ParseColorError.UnknownFunction },
            .{ "hwb(270,0%,0%,x)", ParseColorError.InvalidHwb },
            .{ "lab(0%)", ParseColorError.UnsupportedFunction },
            .{ "lch(0%)", ParseColorError.UnsupportedFunction },
            .{ "cmyk(0,0,0,0)", ParseColorError.UnknownFunction },
            .{ "blood", ParseColorError.UnknownFormat },
            .{ "rgb(255,0,0", ParseColorError.UnknownFormat },
            .{ "x£", ParseColorError.UnknownFormat },
            .{ "x£x", ParseColorError.UnknownFormat },
            .{ "xxx£x", ParseColorError.UnknownFormat },
            .{ "xxxxx£x", ParseColorError.UnknownFormat },
            .{ "\u{1F602}", ParseColorError.UnknownFormat },
        };

        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            for (test_data) |td| {
                const c = Color(ft).parse(td[0]);
                try testing.expectError(td[1], c);
            }
        }
    }
}
