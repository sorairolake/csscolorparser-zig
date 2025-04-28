// SPDX-FileCopyrightText: 2020 Nor Khasyatillah
// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

//! Implementations of CSS color.

const std = @import("std");

const named_colors = @import("named_colors.zig");

const ascii = std.ascii;
const fmt = std.fmt;
const BufPrintError = fmt.BufPrintError;
const Case = fmt.Case;
const math = std.math;
const mem = std.mem;
const testing = std.testing;

const ParseColorError = @import("errors.zig").ParseColorError;

/// This type represents a CSS color defined in the W3C's
/// [CSS Color Module Level 4](https://www.w3.org/TR/css-color-4/).
///
/// The type of `T` must be a floating-point type.
pub fn Color(comptime T: type) type {
    if (@typeInfo(T) != .float)
        @compileError("`" ++ @typeName(T) ++ "` is not a floating-point type");

    return struct {
        /// The red component.
        ///
        /// The value must be in the range of 0.0 to 1.0.
        red: T = 0.0,

        /// The green component.
        ///
        /// The value must be in the range of 0.0 to 1.0.
        green: T = 0.0,

        /// The blue component.
        ///
        /// The value must be in the range of 0.0 to 1.0.
        blue: T = 0.0,

        /// The alpha component.
        ///
        /// The value must be in the range of 0.0 to 1.0.
        alpha: T = 1.0,

        const Self = @This();

        /// Creates a new CSS color with the given components.
        ///
        /// If the value is out of range, this method restricts it to the valid
        /// range.
        pub fn init(red: T, green: T, blue: T, alpha: T) Self {
            return .{
                .red = Self.clamp01(red),
                .green = Self.clamp01(green),
                .blue = Self.clamp01(blue),
                .alpha = Self.clamp01(alpha),
            };
        }

        test init {
            const color = Color(f64).init(1.23, 0.5, -0.01, 1.01);
            try testing.expectEqual(
                .{ 1.0, 0.5, 0.0, 1.0 },
                .{ color.red, color.green, color.blue, color.alpha },
            );
        }

        /// Restricts the values to the valid range.
        pub fn clamp(self: *Self) void {
            self.red = Self.clamp01(self.red);
            self.green = Self.clamp01(self.green);
            self.blue = Self.clamp01(self.blue);
            self.alpha = Self.clamp01(self.alpha);
        }

        test clamp {
            var color = Color(f64){ .red = 1.23, .green = 0.5, .blue = -0.01, .alpha = 1.01 };
            color.clamp();
            try testing.expectEqual(
                .{ 1.0, 0.5, 0.0, 1.0 },
                .{ color.red, color.green, color.blue, color.alpha },
            );
        }

        /// Creates a `Color` from
        /// [RGBA8 color](https://www.w3.org/TR/css-color-4/#numeric-srgb)
        /// values.
        pub fn fromRgba8(red: u8, green: u8, blue: u8, alpha: u8) Self {
            return Self.init(
                @as(T, @floatFromInt(red)) / math.maxInt(u8),
                @as(T, @floatFromInt(green)) / math.maxInt(u8),
                @as(T, @floatFromInt(blue)) / math.maxInt(u8),
                @as(T, @floatFromInt(alpha)) / math.maxInt(u8),
            );
        }

        test fromRgba8 {
            const color = Color(f64).fromRgba8(255, 0, 0, 255);
            try testing.expectEqual(.{ 255, 0, 0, 255 }, color.toRgba8());
        }

        /// Creates a `Color` from linear-light RGB values.
        pub fn fromLinearRgb(red: T, green: T, blue: T, alpha: T) Self {
            const inner = struct {
                pub fn fromLinear(x: T) T {
                    return if (x >= 0.003_130_8)
                        1.055 * math.pow(T, x, 1.0 / 2.4) - 0.055
                    else
                        12.92 * x;
                }
            };
            return Self.init(
                inner.fromLinear(red),
                inner.fromLinear(green),
                inner.fromLinear(blue),
                alpha,
            );
        }

        test fromLinearRgb {
            const color = Color(f64).fromLinearRgb(1.0, 0.0, 0.0, 1.0);
            try testing.expectEqual(.{ 255, 0, 0, 255 }, color.toRgba8());
        }

        /// Creates a `Color` from
        /// [HSL color](https://www.w3.org/TR/css-color-4/#the-hsl-notation)
        /// values.
        pub fn fromHsl(hue: T, saturation: T, lightness: T, alpha: T) Self {
            const r, const g, const b = Self.hslToRgb(
                Self.normalizeAngle(hue),
                Self.clamp01(saturation),
                Self.clamp01(lightness),
            );
            return Self.init(r, g, b, alpha);
        }

        test fromHsl {
            const color = Color(f64).fromHsl(360.0, 1.0, 0.5, 1.0);
            try testing.expectEqual(.{ 255, 0, 0, 255 }, color.toRgba8());
        }

        /// Creates a `Color` from
        /// [HWB color](https://www.w3.org/TR/css-color-4/#the-hwb-notation)
        /// values.
        pub fn fromHwb(hue: T, white: T, black: T, alpha: T) Self {
            const inner = struct {
                pub fn hwbToRgb(h: T, w: T, b: T) [3]T {
                    if ((w + b) >= 1.0) {
                        const l = w / (w + b);
                        return .{ l, l, l };
                    }

                    var rgb = Self.hslToRgb(h, 1.0, 0.5);
                    rgb[0] = rgb[0] * (1.0 - w - b) + w;
                    rgb[1] = rgb[1] * (1.0 - w - b) + w;
                    rgb[2] = rgb[2] * (1.0 - w - b) + w;
                    return rgb;
                }
            };
            const r, const g, const b = inner.hwbToRgb(
                Self.normalizeAngle(hue),
                Self.clamp01(white),
                Self.clamp01(black),
            );
            return Self.init(r, g, b, alpha);
        }

        test fromHwb {
            const color = Color(f64).fromHwb(0.0, 0.0, 0.0, 1.0);
            try testing.expectEqual(.{ 255, 0, 0, 255 }, color.toRgba8());
        }

        /// Creates a `Color` from
        /// [Oklab color](https://www.w3.org/TR/css-color-4/#ok-lab) values.
        pub fn fromOklab(lightness: T, a: T, b: T, alpha: T) Self {
            const l = math.pow(T, lightness + 0.396_337_777_4 * a + 0.215_803_757_3 * b, 3);
            const m = math.pow(T, lightness - 0.105_561_345_8 * a - 0.063_854_172_8 * b, 3);
            const s = math.pow(T, lightness - 0.089_484_177_5 * a - 1.291_485_548_0 * b, 3);

            const r = 4.076_741_662_1 * l - 3.307_711_591_3 * m + 0.230_969_929_2 * s;
            const g = -1.268_438_004_6 * l + 2.609_757_401_1 * m - 0.341_319_396_5 * s;
            const ib = -0.004_196_086_3 * l - 0.703_418_614_7 * m + 1.707_614_701_0 * s;

            return Self.fromLinearRgb(r, g, ib, alpha);
        }

        test fromOklab {
            const color = Color(f64).fromOklab(
                0.627_915_193_996_980_9,
                0.224_903_230_866_107_1,
                0.125_802_870_124_518_02,
                1.0,
            );
            try testing.expectEqual(.{ 255, 0, 0, 255 }, color.toRgba8());
        }

        /// Creates a `Color` from
        /// [OKLCh color](https://www.w3.org/TR/css-color-4/#ok-lab) values.
        pub fn fromOklch(lightness: T, chroma: T, hue: T, alpha: T) Self {
            return Self.fromOklab(lightness, chroma * @cos(hue), chroma * @sin(hue), alpha);
        }

        /// Parses a `Color` from a CSS color string.
        pub fn parse(str: []const u8) ParseColorError!Self {
            const inner = struct {
                pub fn parseHex(s: []const u8) ParseColorError!Self {
                    const inner = struct {
                        pub fn parseSingleDigit(digit: []const u8) ParseColorError!u8 {
                            const n = fmt.parseUnsigned(u8, digit, 16) catch
                                return error.InvalidHex;
                            return (n << 4) | n;
                        }
                    };
                    for (s) |c| {
                        if (!ascii.isAscii(c)) return error.InvalidHex;
                    }

                    const n = s.len;

                    switch (n) {
                        3, 4 => {
                            const r = try inner.parseSingleDigit(s[0..1]);
                            const g = try inner.parseSingleDigit(s[1..2]);
                            const b = try inner.parseSingleDigit(s[2..3]);

                            const a = if (n == 4)
                                try inner.parseSingleDigit(s[3..4])
                            else
                                math.maxInt(u8);

                            return Self.fromRgba8(r, g, b, a);
                        },
                        6, 8 => {
                            const r = fmt.parseUnsigned(u8, s[0..2], 16) catch
                                return error.InvalidHex;
                            const g = fmt.parseUnsigned(u8, s[2..4], 16) catch
                                return error.InvalidHex;
                            const b = fmt.parseUnsigned(u8, s[4..6], 16) catch
                                return error.InvalidHex;

                            const a = if (n == 8)
                                fmt.parseUnsigned(u8, s[6..8], 16) catch
                                    return error.InvalidHex
                            else
                                math.maxInt(u8);

                            return Self.fromRgba8(r, g, b, a);
                        },
                        else => return error.InvalidHex,
                    }
                }

                pub fn parsePercentOrFloat(s: []const u8) ?struct { T, bool } {
                    if (ascii.endsWithIgnoreCase(s, "%")) {
                        const t = fmt.parseFloat(T, s[0..(s.len - 1)]) catch return null;
                        return .{ t / 100.0, true };
                    } else {
                        const t = fmt.parseFloat(T, s) catch return null;
                        return .{ t, false };
                    }
                }

                test "parsePercentOrFloat" {
                    {
                        const float_types = [_]type{f64};
                        inline for (float_types) |ft| {
                            const test_data = [_]struct { []const u8, struct { ft, bool } }{
                                .{ "0%", .{ 0.0, true } },
                                .{ "100%", .{ 1.0, true } },
                                .{ "50%", .{ 0.5, true } },
                                .{ "0", .{ 0.0, false } },
                                .{ "1", .{ 1.0, false } },
                                .{ "0.5", .{ 0.5, false } },
                                .{ "100.0", .{ 100.0, false } },
                                .{ "-23.7", .{ -23.7, false } },
                            };
                            for (test_data) |td| {
                                const v = @This().parsePercentOrFloat(td[0]).?;
                                try testing.expectEqual(td[1][0], v[0]);
                                try testing.expectEqual(td[1][1], v[1]);
                            }
                        }
                    }
                    {
                        const test_data = [_][]const u8{ "%", "1x" };
                        for (test_data) |td| {
                            const parsed = @This().parsePercentOrFloat(td);
                            try testing.expectEqual(null, parsed);
                        }
                    }
                }

                pub fn parsePercentOr255(s: []const u8) ?struct { T, bool } {
                    if (ascii.endsWithIgnoreCase(s, "%")) {
                        const t = fmt.parseFloat(T, s[0..(s.len - 1)]) catch return null;
                        return .{ t / 100.0, true };
                    } else {
                        const t = fmt.parseFloat(T, s) catch return null;
                        return .{ t / 255.0, false };
                    }
                }

                test "parsePercentOr255" {
                    {
                        const float_types = [_]type{ f16, f32, f64, f80, f128 };
                        inline for (float_types) |ft| {
                            const test_data = [_]struct { []const u8, struct { ft, bool } }{
                                .{ "0%", .{ 0.0, true } },
                                .{ "100%", .{ 1.0, true } },
                                .{ "50%", .{ 0.5, true } },
                                .{ "-100%", .{ -1.0, true } },
                                .{ "0", .{ 0.0, false } },
                                .{ "255", .{ 1.0, false } },
                                .{ "127.5", .{ 0.5, false } },
                            };
                            for (test_data) |td| {
                                const v = @This().parsePercentOr255(td[0]).?;
                                try testing.expectEqual(td[1][0], v[0]);
                                try testing.expectEqual(td[1][1], v[1]);
                            }
                        }
                    }
                    {
                        const test_data = [_][]const u8{ "%", "255x" };
                        for (test_data) |td| {
                            const parsed = @This().parsePercentOr255(td);
                            try testing.expectEqual(null, parsed);
                        }
                    }
                }

                pub fn parseAngle(s: []const u8) ?T {
                    if (ascii.endsWithIgnoreCase(s, "deg")) {
                        return fmt.parseFloat(T, s[0..(s.len - 3)]) catch null;
                    }
                    if (ascii.endsWithIgnoreCase(s, "grad")) {
                        const t = fmt.parseFloat(T, s[0..(s.len - 4)]) catch return null;
                        return t * 360.0 / 400.0;
                    }
                    if (ascii.endsWithIgnoreCase(s, "rad")) {
                        const t = fmt.parseFloat(T, s[0..(s.len - 3)]) catch return null;
                        return math.radiansToDegrees(t);
                    }
                    if (ascii.endsWithIgnoreCase(s, "turn")) {
                        const t = fmt.parseFloat(T, s[0..(s.len - 4)]) catch return null;
                        return t * 360.0;
                    }
                    return fmt.parseFloat(T, s) catch null;
                }

                test "parseAngle" {
                    {
                        const float_types = [_]type{f64};
                        inline for (float_types) |ft| {
                            const test_data = [_]struct { []const u8, ft }{
                                .{ "360", 360.0 },
                                .{ "127.356", 127.356 },
                                .{ "+120deg", 120.0 },
                                .{ "90deg", 90.0 },
                                .{ "-127deg", -127.0 },
                                .{ "100grad", 90.0 },
                                .{ "1.5707963267948966rad", 90.0 },
                                .{ "0.25turn", 90.0 },
                                .{ "-0.25turn", -90.0 },
                            };
                            for (test_data) |td| {
                                const v = @This().parseAngle(td[0]).?;
                                try testing.expectEqual(td[1], v);
                            }
                        }
                    }
                    {
                        const test_data = [_][]const u8{ "O", "Odeg", "rad" };
                        for (test_data) |td| {
                            const parsed = @This().parseAngle(td);
                            try testing.expectEqual(null, parsed);
                        }
                    }
                }

                pub fn remap(t: T, a: T, b: T, c: T, d: T) T {
                    return (t - a) * ((d - c) / (b - a)) + c;
                }
            };
            var buf: [1 << 8]u8 = undefined;
            const lower = ascii.lowerString(&buf, mem.trim(u8, str, &ascii.whitespace));

            if (mem.eql(u8, lower, "transparent")) return Self.init(0.0, 0.0, 0.0, 0.0);

            if (named_colors.named_colors.get(lower)) |rgb|
                return Self.fromRgba8(rgb[0], rgb[1], rgb[2], math.maxInt(u8));

            if (ascii.startsWithIgnoreCase(lower, "#")) return inner.parseHex(lower[1..]);

            if (ascii.indexOfIgnoreCase(lower, "(")) |i| {
                if (ascii.endsWithIgnoreCase(lower, ")")) {
                    const fn_name = mem.trimRight(u8, lower[0..i], &ascii.whitespace);
                    const s = lower[(i + 1)..(lower.len - 1)];
                    mem.replaceScalar(u8, s, ',', ' ');
                    mem.replaceScalar(u8, s, '/', ' ');
                    var iter = mem.tokenizeAny(u8, s, &ascii.whitespace);
                    var params_list = mem.zeroes([5][]const u8);
                    var j: u3 = 0;
                    while (iter.next()) |param| : (j += 1) {
                        if (j >= params_list.len) break;
                        params_list[j] = param;
                    }
                    const params = params_list[0..j];
                    const params_len = params.len;

                    if (mem.eql(u8, fn_name, "rgb") or mem.eql(u8, fn_name, "rgba")) {
                        switch (params_len) {
                            3, 4 => {},
                            else => return error.InvalidRgb,
                        }

                        const r = inner.parsePercentOr255(params[0]) orelse return error.InvalidRgb;
                        const g = inner.parsePercentOr255(params[1]) orelse return error.InvalidRgb;
                        const b = inner.parsePercentOr255(params[2]) orelse return error.InvalidRgb;

                        const a = if (params_len == 4)
                            inner.parsePercentOrFloat(params[3]) orelse return error.InvalidRgb
                        else
                            .{ 1.0, true };

                        return if ((r[1] == g[1]) and (g[1] == b[1]))
                            Self.init(r[0], g[0], b[0], a[0])
                        else
                            error.InvalidRgb;
                    }
                    if (mem.eql(u8, fn_name, "hsl") or mem.eql(u8, fn_name, "hsla")) {
                        switch (params_len) {
                            3, 4 => {},
                            else => return error.InvalidHsl,
                        }

                        const h = inner.parseAngle(params[0]) orelse return error.InvalidHsl;
                        const saturation = inner.parsePercentOrFloat(params[1]) orelse
                            return error.InvalidHsl;
                        const l = inner.parsePercentOrFloat(params[2]) orelse
                            return error.InvalidHsl;

                        const a = if (params_len == 4)
                            inner.parsePercentOrFloat(params[3]) orelse return error.InvalidHsl
                        else
                            .{ 1.0, true };

                        return if (saturation[1] == l[1])
                            Self.fromHsl(h, saturation[0], l[0], a[0])
                        else
                            error.InvalidHsl;
                    }
                    if (mem.eql(u8, fn_name, "hwb")) {
                        switch (params_len) {
                            3, 4 => {},
                            else => return error.InvalidHwb,
                        }

                        const h = inner.parseAngle(params[0]) orelse return error.InvalidHwb;
                        const w = inner.parsePercentOrFloat(params[1]) orelse
                            return error.InvalidHwb;
                        const b = inner.parsePercentOrFloat(params[2]) orelse
                            return error.InvalidHwb;

                        const a = if (params_len == 4)
                            inner.parsePercentOrFloat(params[3]) orelse return error.InvalidHwb
                        else
                            .{ 1.0, true };

                        return if (w[1] == b[1])
                            Self.fromHwb(h, w[0], b[0], a[0])
                        else
                            error.InvalidHwb;
                    }
                    if (mem.eql(u8, fn_name, "oklab")) {
                        switch (params_len) {
                            3, 4 => {},
                            else => return error.InvalidOklab,
                        }

                        const l = inner.parsePercentOrFloat(params[0]) orelse
                            return error.InvalidOklab;
                        var a = inner.parsePercentOrFloat(params[1]) orelse
                            return error.InvalidOklab;
                        var b = inner.parsePercentOrFloat(params[2]) orelse
                            return error.InvalidOklab;

                        const alpha = if (params_len == 4)
                            inner.parsePercentOrFloat(params[3]) orelse return error.InvalidOklab
                        else
                            .{ 1.0, true };

                        if (a[1]) a[0] = inner.remap(a[0], -1.0, 1.0, -0.4, 0.4);
                        if (b[1]) b[0] = inner.remap(b[0], -1.0, 1.0, -0.4, 0.4);
                        return Self.fromOklab(@max(l[0], 0.0), a[0], b[0], alpha[0]);
                    }
                    if (mem.eql(u8, fn_name, "oklch")) {
                        switch (params_len) {
                            3, 4 => {},
                            else => return error.InvalidOklch,
                        }

                        const l = inner.parsePercentOrFloat(params[0]) orelse
                            return error.InvalidOklch;
                        var c = inner.parsePercentOrFloat(params[1]) orelse
                            return error.InvalidOklch;
                        const h = inner.parseAngle(params[2]) orelse return error.InvalidOklch;

                        const alpha = if (params_len == 4)
                            inner.parsePercentOrFloat(params[3]) orelse return error.InvalidOklch
                        else
                            .{ 1.0, true };

                        if (c[1]) c[0] *= 0.4;
                        return Self.fromOklch(
                            @max(l[0], 0.0),
                            @max(c[0], 0.0),
                            math.degreesToRadians(h),
                            alpha[0],
                        );
                    }
                    return if (mem.eql(u8, fn_name, "lab") or mem.eql(u8, fn_name, "lch") or mem.eql(u8, fn_name, "color"))
                        error.UnsupportedFunction
                    else
                        error.UnknownFunction;
                }
            }

            return inner.parseHex(lower) catch error.UnknownFormat;
        }

        test parse {
            const color = try Color(f64).parse("#ff0");
            try testing.expectEqual(
                .{ 1.0, 1.0, 0.0, 1.0 },
                .{ color.red, color.green, color.blue, color.alpha },
            );
            try testing.expectEqual(.{ 255, 255, 0, 255 }, color.toRgba8());
            var buf: [7]u8 = undefined;
            const hex = try color.toHexString(&buf);
            try testing.expectEqualStrings("#ffff00", hex);
        }

        /// Returns the
        /// [color name](https://www.w3.org/TR/css-color-4/#named-colors) of
        /// this `Color`, returning `null` if it is not available.
        pub fn name(self: Self) ?[]const u8 {
            const rgb = self.toRgba8()[0..3];
            for (named_colors.named_colors.keys()) |key| {
                if (mem.eql(u8, &named_colors.named_colors.get(key).?, rgb)) return key;
            }
            return null;
        }

        test name {
            const color = try Color(f64).parse("#f0f8ff");
            try testing.expectEqualStrings("aliceblue", color.name().?);
        }

        /// Returns an array of
        /// [RGBA8 color](https://www.w3.org/TR/css-color-4/#numeric-srgb)
        /// values.
        pub fn toRgba8(self: Self) [4]u8 {
            return .{
                @intFromFloat(@round(self.red * math.maxInt(u8))),
                @intFromFloat(@round(self.green * math.maxInt(u8))),
                @intFromFloat(@round(self.blue * math.maxInt(u8))),
                @intFromFloat(@round(self.alpha * math.maxInt(u8))),
            };
        }

        test toRgba8 {
            const color = Color(f64).init(1.0, 0.0, 0.0, 1.0);
            try testing.expectEqual(.{ 255, 0, 0, 255 }, color.toRgba8());
        }

        /// Returns an array of linear-light RGB values.
        pub fn toLinearRgb(self: Self) [4]T {
            const inner = struct {
                pub fn toLinear(x: T) T {
                    return if (x >= 0.04045) math.pow(T, (x + 0.055) / 1.055, 2.4) else x / 12.92;
                }
            };
            return .{
                inner.toLinear(self.red),
                inner.toLinear(self.green),
                inner.toLinear(self.blue),
                self.alpha,
            };
        }

        test toLinearRgb {
            const color = Color(f64).init(1.0, 0.0, 0.0, 1.0);
            try testing.expectEqual(.{ 1.0, 0.0, 0.0, 1.0 }, color.toLinearRgb());
        }

        /// Returns an array of
        /// [HSL color](https://www.w3.org/TR/css-color-4/#the-hsl-notation)
        /// values.
        pub fn toHsl(self: Self) [4]T {
            const h, const s, const l = Self.rgbToHsl(self.red, self.green, self.blue);
            return .{ h, s, l, self.alpha };
        }

        test toHsl {
            const color = Color(f64).init(1.0, 0.0, 0.0, 1.0);
            try testing.expectEqual(.{ 0.0, 1.0, 0.5, 1.0 }, color.toHsl());
        }

        /// Returns an array of
        /// [HWB color](https://www.w3.org/TR/css-color-4/#the-hwb-notation)
        /// values.
        pub fn toHwb(self: Self) [4]T {
            const inner = struct {
                pub fn rgbToHwb(r: T, g: T, b: T) [3]T {
                    const hue = Self.rgbToHsl(r, g, b)[0];
                    const white = @min(r, @min(g, b));
                    const black = 1.0 - @max(r, @max(g, b));
                    return .{ hue, white, black };
                }
            };
            const h, const w, const b = inner.rgbToHwb(self.red, self.green, self.blue);
            return .{ h, w, b, self.alpha };
        }

        test toHwb {
            const color = Color(f64).init(1.0, 0.0, 0.0, 1.0);
            try testing.expectEqual(.{ 0.0, 0.0, 0.0, 1.0 }, color.toHwb());
        }

        /// Returns an array of
        /// [Oklab color](https://www.w3.org/TR/css-color-4/#ok-lab) values.
        pub fn toOklab(self: Self) [4]T {
            const r, const g, const blue = self.toLinearRgb()[0..3].*;
            const l = math.cbrt(0.412_221_470_8 * r + 0.536_332_536_3 * g + 0.051_445_992_9 * blue);
            const m = math.cbrt(0.211_903_498_2 * r + 0.680_699_545_1 * g + 0.107_396_956_6 * blue);
            const s = math.cbrt(0.088_302_461_9 * r + 0.281_718_837_6 * g + 0.629_978_700_5 * blue);
            const lightness = 0.210_454_255_3 * l + 0.793_617_785_0 * m - 0.004_072_046_8 * s;
            const a = 1.977_998_495_1 * l - 2.428_592_205_0 * m + 0.450_593_709_9 * s;
            const b = 0.025_904_037_1 * l + 0.782_771_766_2 * m - 0.808_675_766_0 * s;
            return .{ lightness, a, b, self.alpha };
        }

        /// Returns the
        /// [RGB hexadecimal color string](https://www.w3.org/TR/css-color-4/#hex-notation)
        /// of this `Color`.
        pub fn toHexString(self: Self, buf: []u8) BufPrintError![]u8 {
            const r, const g, const b, const a = self.toRgba8();

            return if (a < math.maxInt(u8))
                fmt.bufPrint(buf, "#{x:0>2}{x:0>2}{x:0>2}{x:0>2}", .{ r, g, b, a })
            else
                fmt.bufPrint(buf, "#{x:0>2}{x:0>2}{x:0>2}", .{ r, g, b });
        }

        test toHexString {
            const color = Color(f64).init(1.0, 0.0, 0.0, 1.0);
            var buf: [7]u8 = undefined;
            const hex = try color.toHexString(&buf);
            try testing.expectEqualStrings("#ff0000", hex);
        }

        fn hslToRgb(h: T, s: T, l: T) [3]T {
            const inner = struct {
                pub fn hueToRgb(n1: T, n2: T, ih: T) T {
                    const iih = @mod(@mod(ih, 6.0) + 6.0, 6.0);

                    if (iih < 1.0) return n1 + ((n2 - n1) * iih);

                    if (iih < 3.0) return n2;

                    if (iih < 4.0) return n1 + ((n2 - n1) * (4.0 - iih));

                    return n1;
                }
            };

            if (s == 0.0) return .{ l, l, l };

            const n2 = if (l < 0.5) l * (1.0 + s) else l + s - (l * s);

            const n1 = 2.0 * l - n2;
            const hp = h / 60.0;
            const r = inner.hueToRgb(n1, n2, hp + 2.0);
            const g = inner.hueToRgb(n1, n2, hp);
            const b = inner.hueToRgb(n1, n2, hp - 2.0);
            return .{ r, g, b };
        }

        fn rgbToHsl(r: T, g: T, b: T) [3]T {
            const min = @min(r, @min(g, b));
            const max = @max(r, @max(g, b));
            const l = (max + min) / 2.0;

            if (min == max) return .{ 0.0, 0.0, l };

            const d = max - min;

            const s = if (l < 0.5) d / (max + min) else d / (2.0 - max - min);

            const dr = (max - r) / d;
            const dg = (max - g) / d;
            const db = (max - b) / d;

            var h = if (r == max) db - dg else if (g == max) 2.0 + dr - db else 4.0 + dg - dr;

            h = @mod((h * 60.0), 360.0);
            return .{ Self.normalizeAngle(h), s, l };
        }

        fn normalizeAngle(t: T) T {
            var it = @mod(t, 360.0);
            if (it < 0.0) {
                it += 360.0;
            }
            return it;
        }

        fn clamp01(t: T) T {
            return math.clamp(t, 0.0, 1.0);
        }
    };
}

test "normalizeAngle" {
    const float_types = [_]type{ f16, f32, f64, f80, f128 };
    inline for (float_types) |ft| {
        const data = [_][2]ft{
            .{ 0.0, 0.0 },
            .{ 360.0, 0.0 },
            .{ 400.0, 40.0 },
            .{ 1155.0, 75.0 },
            .{ -360.0, 0.0 },
            .{ -90.0, 270.0 },
            .{ -765.0, 315.0 },
        };
        for (data) |d| {
            const c = Color(ft).normalizeAngle(d[0]);
            try testing.expectEqual(d[1], c);
        }
    }
}
