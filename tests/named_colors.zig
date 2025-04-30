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
    const skip_list = [_][]const u8{ "aqua", "cyan", "fuchsia", "magenta" };
    const gray_list = [_][]const u8{ "gray", "grey" };

    {
        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            outer: for (csscolorparser.named_colors.keys(), csscolorparser.named_colors.values()) |name, rgb| {
                const c1 = try Color(ft).parse(name);
                try testing.expectEqual(rgb, c1.toRgba8()[0..3].*);

                for (skip_list) |nc| {
                    if (ascii.eqlIgnoreCase(name, nc)) continue :outer;
                }
                for (gray_list) |nc| {
                    if (ascii.indexOfIgnoreCase(name, nc) != null) continue :outer;
                }
                try testing.expectEqualStrings(name, c1.name().?);

                const r, const g, const b = rgb;
                const c2 = Color(ft).fromRgba8(r, g, b, math.maxInt(u8));
                try testing.expectEqualStrings(name, c2.name().?);
            }
        }
    }

    {
        // Named colors and their hex color notations.
        const test_data = [_][2][]const u8{
            .{ "aliceblue", "#f0f8ff" },
            .{ "antiquewhite", "#faebd7" },
            .{ "aqua", "#00ffff" },
            .{ "aquamarine", "#7fffd4" },
            .{ "azure", "#f0ffff" },
            .{ "beige", "#f5f5dc" },
            .{ "bisque", "#ffe4c4" },
            .{ "black", "#000000" },
            .{ "blanchedalmond", "#ffebcd" },
            .{ "blue", "#0000ff" },
            .{ "blueviolet", "#8a2be2" },
            .{ "brown", "#a52a2a" },
            .{ "burlywood", "#deb887" },
            .{ "cadetblue", "#5f9ea0" },
            .{ "chartreuse", "#7fff00" },
            .{ "chocolate", "#d2691e" },
            .{ "coral", "#ff7f50" },
            .{ "cornflowerblue", "#6495ed" },
            .{ "cornsilk", "#fff8dc" },
            .{ "crimson", "#dc143c" },
            .{ "cyan", "#00ffff" },
            .{ "darkblue", "#00008b" },
            .{ "darkcyan", "#008b8b" },
            .{ "darkgoldenrod", "#b8860b" },
            .{ "darkgray", "#a9a9a9" },
            .{ "darkgreen", "#006400" },
            .{ "darkgrey", "#a9a9a9" },
            .{ "darkkhaki", "#bdb76b" },
            .{ "darkmagenta", "#8b008b" },
            .{ "darkolivegreen", "#556b2f" },
            .{ "darkorange", "#ff8c00" },
            .{ "darkorchid", "#9932cc" },
            .{ "darkred", "#8b0000" },
            .{ "darksalmon", "#e9967a" },
            .{ "darkseagreen", "#8fbc8f" },
            .{ "darkslateblue", "#483d8b" },
            .{ "darkslategray", "#2f4f4f" },
            .{ "darkslategrey", "#2f4f4f" },
            .{ "darkturquoise", "#00ced1" },
            .{ "darkviolet", "#9400d3" },
            .{ "deeppink", "#ff1493" },
            .{ "deepskyblue", "#00bfff" },
            .{ "dimgray", "#696969" },
            .{ "dimgrey", "#696969" },
            .{ "dodgerblue", "#1e90ff" },
            .{ "firebrick", "#b22222" },
            .{ "floralwhite", "#fffaf0" },
            .{ "forestgreen", "#228b22" },
            .{ "fuchsia", "#ff00ff" },
            .{ "gainsboro", "#dcdcdc" },
            .{ "ghostwhite", "#f8f8ff" },
            .{ "gold", "#ffd700" },
            .{ "goldenrod", "#daa520" },
            .{ "gray", "#808080" },
            .{ "green", "#008000" },
            .{ "greenyellow", "#adff2f" },
            .{ "grey", "#808080" },
            .{ "honeydew", "#f0fff0" },
            .{ "hotpink", "#ff69b4" },
            .{ "indianred", "#cd5c5c" },
            .{ "indigo", "#4b0082" },
            .{ "ivory", "#fffff0" },
            .{ "khaki", "#f0e68c" },
            .{ "lavender", "#e6e6fa" },
            .{ "lavenderblush", "#fff0f5" },
            .{ "lawngreen", "#7cfc00" },
            .{ "lemonchiffon", "#fffacd" },
            .{ "lightblue", "#add8e6" },
            .{ "lightcoral", "#f08080" },
            .{ "lightcyan", "#e0ffff" },
            .{ "lightgoldenrodyellow", "#fafad2" },
            .{ "lightgray", "#d3d3d3" },
            .{ "lightgreen", "#90ee90" },
            .{ "lightgrey", "#d3d3d3" },
            .{ "lightpink", "#ffb6c1" },
            .{ "lightsalmon", "#ffa07a" },
            .{ "lightseagreen", "#20b2aa" },
            .{ "lightskyblue", "#87cefa" },
            .{ "lightslategray", "#778899" },
            .{ "lightslategrey", "#778899" },
            .{ "lightsteelblue", "#b0c4de" },
            .{ "lightyellow", "#ffffe0" },
            .{ "lime", "#00ff00" },
            .{ "limegreen", "#32cd32" },
            .{ "linen", "#faf0e6" },
            .{ "magenta", "#ff00ff" },
            .{ "maroon", "#800000" },
            .{ "mediumaquamarine", "#66cdaa" },
            .{ "mediumblue", "#0000cd" },
            .{ "mediumorchid", "#ba55d3" },
            .{ "mediumpurple", "#9370db" },
            .{ "mediumseagreen", "#3cb371" },
            .{ "mediumslateblue", "#7b68ee" },
            .{ "mediumspringgreen", "#00fa9a" },
            .{ "mediumturquoise", "#48d1cc" },
            .{ "mediumvioletred", "#c71585" },
            .{ "midnightblue", "#191970" },
            .{ "mintcream", "#f5fffa" },
            .{ "mistyrose", "#ffe4e1" },
            .{ "moccasin", "#ffe4b5" },
            .{ "navajowhite", "#ffdead" },
            .{ "navy", "#000080" },
            .{ "oldlace", "#fdf5e6" },
            .{ "olive", "#808000" },
            .{ "olivedrab", "#6b8e23" },
            .{ "orange", "#ffa500" },
            .{ "orangered", "#ff4500" },
            .{ "orchid", "#da70d6" },
            .{ "palegoldenrod", "#eee8aa" },
            .{ "palegreen", "#98fb98" },
            .{ "paleturquoise", "#afeeee" },
            .{ "palevioletred", "#db7093" },
            .{ "papayawhip", "#ffefd5" },
            .{ "peachpuff", "#ffdab9" },
            .{ "peru", "#cd853f" },
            .{ "pink", "#ffc0cb" },
            .{ "plum", "#dda0dd" },
            .{ "powderblue", "#b0e0e6" },
            .{ "purple", "#800080" },
            .{ "rebeccapurple", "#663399" },
            .{ "red", "#ff0000" },
            .{ "rosybrown", "#bc8f8f" },
            .{ "royalblue", "#4169e1" },
            .{ "saddlebrown", "#8b4513" },
            .{ "salmon", "#fa8072" },
            .{ "sandybrown", "#f4a460" },
            .{ "seagreen", "#2e8b57" },
            .{ "seashell", "#fff5ee" },
            .{ "sienna", "#a0522d" },
            .{ "silver", "#c0c0c0" },
            .{ "skyblue", "#87ceeb" },
            .{ "slateblue", "#6a5acd" },
            .{ "slategray", "#708090" },
            .{ "slategrey", "#708090" },
            .{ "snow", "#fffafa" },
            .{ "springgreen", "#00ff7f" },
            .{ "steelblue", "#4682b4" },
            .{ "tan", "#d2b48c" },
            .{ "teal", "#008080" },
            .{ "thistle", "#d8bfd8" },
            .{ "tomato", "#ff6347" },
            .{ "turquoise", "#40e0d0" },
            .{ "violet", "#ee82ee" },
            .{ "wheat", "#f5deb3" },
            .{ "white", "#ffffff" },
            .{ "whitesmoke", "#f5f5f5" },
            .{ "yellow", "#ffff00" },
            .{ "yellowgreen", "#9acd32" },
        };

        var buf: [9]u8 = undefined;
        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            outer: for (test_data) |td| {
                const c1 = try Color(ft).parse(td[0]);
                const hex = try c1.toHexString(&buf);
                try testing.expectEqualStrings(td[1], hex);

                for (skip_list) |nc| {
                    if (ascii.eqlIgnoreCase(td[0], nc)) continue :outer;
                }
                for (gray_list) |nc| {
                    if (ascii.indexOfIgnoreCase(td[0], nc) != null) continue :outer;
                }

                const c2 = try Color(ft).parse(td[1]);
                try testing.expectEqualStrings(td[0], c2.name().?);
            }
        }
    }

    {
        const float_types = [_]type{ f16, f32, f64, f80, f128 };
        inline for (float_types) |ft| {
            // Colors without names.
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

    {
        // 8 digits fully opaque hex color notations and their named colors.
        const test_data = [_][2][]const u8{
            .{ "#f0f8ffff", "aliceblue" },
            .{ "#faebd7ff", "antiquewhite" },
            .{ "#00ffffff", "aqua" },
            .{ "#7fffd4ff", "aquamarine" },
            .{ "#f0ffffff", "azure" },
            .{ "#f5f5dcff", "beige" },
            .{ "#ffe4c4ff", "bisque" },
            .{ "#000000ff", "black" },
            .{ "#ffebcdff", "blanchedalmond" },
            .{ "#0000ffff", "blue" },
            .{ "#8a2be2ff", "blueviolet" },
            .{ "#a52a2aff", "brown" },
            .{ "#deb887ff", "burlywood" },
            .{ "#5f9ea0ff", "cadetblue" },
            .{ "#7fff00ff", "chartreuse" },
            .{ "#d2691eff", "chocolate" },
            .{ "#ff7f50ff", "coral" },
            .{ "#6495edff", "cornflowerblue" },
            .{ "#fff8dcff", "cornsilk" },
            .{ "#dc143cff", "crimson" },
            .{ "#00ffffff", "cyan" },
            .{ "#00008bff", "darkblue" },
            .{ "#008b8bff", "darkcyan" },
            .{ "#b8860bff", "darkgoldenrod" },
            .{ "#a9a9a9ff", "darkgray" },
            .{ "#006400ff", "darkgreen" },
            .{ "#a9a9a9ff", "darkgrey" },
            .{ "#bdb76bff", "darkkhaki" },
            .{ "#8b008bff", "darkmagenta" },
            .{ "#556b2fff", "darkolivegreen" },
            .{ "#ff8c00ff", "darkorange" },
            .{ "#9932ccff", "darkorchid" },
            .{ "#8b0000ff", "darkred" },
            .{ "#e9967aff", "darksalmon" },
            .{ "#8fbc8fff", "darkseagreen" },
            .{ "#483d8bff", "darkslateblue" },
            .{ "#2f4f4fff", "darkslategray" },
            .{ "#2f4f4fff", "darkslategrey" },
            .{ "#00ced1ff", "darkturquoise" },
            .{ "#9400d3ff", "darkviolet" },
            .{ "#ff1493ff", "deeppink" },
            .{ "#00bfffff", "deepskyblue" },
            .{ "#696969ff", "dimgray" },
            .{ "#696969ff", "dimgrey" },
            .{ "#1e90ffff", "dodgerblue" },
            .{ "#b22222ff", "firebrick" },
            .{ "#fffaf0ff", "floralwhite" },
            .{ "#228b22ff", "forestgreen" },
            .{ "#ff00ffff", "fuchsia" },
            .{ "#dcdcdcff", "gainsboro" },
            .{ "#f8f8ffff", "ghostwhite" },
            .{ "#ffd700ff", "gold" },
            .{ "#daa520ff", "goldenrod" },
            .{ "#808080ff", "gray" },
            .{ "#008000ff", "green" },
            .{ "#adff2fff", "greenyellow" },
            .{ "#808080ff", "grey" },
            .{ "#f0fff0ff", "honeydew" },
            .{ "#ff69b4ff", "hotpink" },
            .{ "#cd5c5cff", "indianred" },
            .{ "#4b0082ff", "indigo" },
            .{ "#fffff0ff", "ivory" },
            .{ "#f0e68cff", "khaki" },
            .{ "#e6e6faff", "lavender" },
            .{ "#fff0f5ff", "lavenderblush" },
            .{ "#7cfc00ff", "lawngreen" },
            .{ "#fffacdff", "lemonchiffon" },
            .{ "#add8e6ff", "lightblue" },
            .{ "#f08080ff", "lightcoral" },
            .{ "#e0ffffff", "lightcyan" },
            .{ "#fafad2ff", "lightgoldenrodyellow" },
            .{ "#d3d3d3ff", "lightgray" },
            .{ "#90ee90ff", "lightgreen" },
            .{ "#d3d3d3ff", "lightgrey" },
            .{ "#ffb6c1ff", "lightpink" },
            .{ "#ffa07aff", "lightsalmon" },
            .{ "#20b2aaff", "lightseagreen" },
            .{ "#87cefaff", "lightskyblue" },
            .{ "#778899ff", "lightslategray" },
            .{ "#778899ff", "lightslategrey" },
            .{ "#b0c4deff", "lightsteelblue" },
            .{ "#ffffe0ff", "lightyellow" },
            .{ "#00ff00ff", "lime" },
            .{ "#32cd32ff", "limegreen" },
            .{ "#faf0e6ff", "linen" },
            .{ "#ff00ffff", "magenta" },
            .{ "#800000ff", "maroon" },
            .{ "#66cdaaff", "mediumaquamarine" },
            .{ "#0000cdff", "mediumblue" },
            .{ "#ba55d3ff", "mediumorchid" },
            .{ "#9370dbff", "mediumpurple" },
            .{ "#3cb371ff", "mediumseagreen" },
            .{ "#7b68eeff", "mediumslateblue" },
            .{ "#00fa9aff", "mediumspringgreen" },
            .{ "#48d1ccff", "mediumturquoise" },
            .{ "#c71585ff", "mediumvioletred" },
            .{ "#191970ff", "midnightblue" },
            .{ "#f5fffaff", "mintcream" },
            .{ "#ffe4e1ff", "mistyrose" },
            .{ "#ffe4b5ff", "moccasin" },
            .{ "#ffdeadff", "navajowhite" },
            .{ "#000080ff", "navy" },
            .{ "#fdf5e6ff", "oldlace" },
            .{ "#808000ff", "olive" },
            .{ "#6b8e23ff", "olivedrab" },
            .{ "#ffa500ff", "orange" },
            .{ "#ff4500ff", "orangered" },
            .{ "#da70d6ff", "orchid" },
            .{ "#eee8aaff", "palegoldenrod" },
            .{ "#98fb98ff", "palegreen" },
            .{ "#afeeeeff", "paleturquoise" },
            .{ "#db7093ff", "palevioletred" },
            .{ "#ffefd5ff", "papayawhip" },
            .{ "#ffdab9ff", "peachpuff" },
            .{ "#cd853fff", "peru" },
            .{ "#ffc0cbff", "pink" },
            .{ "#dda0ddff", "plum" },
            .{ "#b0e0e6ff", "powderblue" },
            .{ "#800080ff", "purple" },
            .{ "#663399ff", "rebeccapurple" },
            .{ "#ff0000ff", "red" },
            .{ "#bc8f8fff", "rosybrown" },
            .{ "#4169e1ff", "royalblue" },
            .{ "#8b4513ff", "saddlebrown" },
            .{ "#fa8072ff", "salmon" },
            .{ "#f4a460ff", "sandybrown" },
            .{ "#2e8b57ff", "seagreen" },
            .{ "#fff5eeff", "seashell" },
            .{ "#a0522dff", "sienna" },
            .{ "#c0c0c0ff", "silver" },
            .{ "#87ceebff", "skyblue" },
            .{ "#6a5acdff", "slateblue" },
            .{ "#708090ff", "slategray" },
            .{ "#708090ff", "slategrey" },
            .{ "#fffafaff", "snow" },
            .{ "#00ff7fff", "springgreen" },
            .{ "#4682b4ff", "steelblue" },
            .{ "#d2b48cff", "tan" },
            .{ "#008080ff", "teal" },
            .{ "#d8bfd8ff", "thistle" },
            .{ "#ff6347ff", "tomato" },
            .{ "#40e0d0ff", "turquoise" },
            .{ "#ee82eeff", "violet" },
            .{ "#f5deb3ff", "wheat" },
            .{ "#ffffffff", "white" },
            .{ "#f5f5f5ff", "whitesmoke" },
            .{ "#ffff00ff", "yellow" },
            .{ "#9acd32ff", "yellowgreen" },
        };

        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            outer: for (test_data) |td| {
                const c = try Color(ft).parse(td[0]);

                for (skip_list) |nc| {
                    if (ascii.eqlIgnoreCase(td[1], nc)) continue :outer;
                }
                for (gray_list) |nc| {
                    if (ascii.indexOfIgnoreCase(td[1], nc) != null) continue :outer;
                }

                try testing.expectEqualStrings(td[1], c.name().?);
            }
        }
    }

    {
        // Hex color notations that are not fully opaque.
        const test_data = [_][]const u8{
            "#f0f8ff00",
            "#faebd702",
            "#00ffff04",
            "#7fffd406",
            "#f0ffff08",
            "#f5f5dc0a",
            "#ffe4c40c",
            "#0000000e",
            "#ffebcd10",
            "#0000ff12",
            "#8a2be214",
            "#a52a2a16",
            "#deb88718",
            "#5f9ea01a",
            "#7fff001c",
            "#d2691e1e",
            "#ff7f5020",
            "#6495ed22",
            "#fff8dc24",
            "#dc143c26",
            "#00ffff28",
            "#00008b2a",
            "#008b8b2c",
            "#b8860b2e",
            "#a9a9a930",
            "#00640032",
            "#a9a9a934",
            "#bdb76b36",
            "#8b008b38",
            "#556b2f3a",
            "#ff8c003c",
            "#9932cc3e",
            "#8b000040",
            "#e9967a42",
            "#8fbc8f44",
            "#483d8b46",
            "#2f4f4f48",
            "#2f4f4f4a",
            "#00ced14c",
            "#9400d34e",
            "#ff149350",
            "#00bfff52",
            "#69696954",
            "#69696956",
            "#1e90ff58",
            "#b222225a",
            "#fffaf05c",
            "#228b225e",
            "#ff00ff60",
            "#dcdcdc62",
            "#f8f8ff64",
            "#ffd70066",
            "#daa52068",
            "#8080806a",
            "#0080006c",
            "#adff2f6e",
            "#80808070",
            "#f0fff072",
            "#ff69b474",
            "#cd5c5c76",
            "#4b008278",
            "#fffff07a",
            "#f0e68c7c",
            "#e6e6fa7e",
            "#fff0f580",
            "#7cfc0082",
            "#fffacd84",
            "#add8e686",
            "#f0808088",
            "#e0ffff8a",
            "#fafad28c",
            "#d3d3d38e",
            "#90ee9090",
            "#d3d3d392",
            "#ffb6c194",
            "#ffa07a96",
            "#20b2aa98",
            "#87cefa9a",
            "#7788999c",
            "#7788999e",
            "#b0c4dea0",
            "#ffffe0a2",
            "#00ff00a4",
            "#32cd32a6",
            "#faf0e6a8",
            "#ff00ffaa",
            "#800000ac",
            "#66cdaaae",
            "#0000cdb0",
            "#ba55d3b2",
            "#9370dbb4",
            "#3cb371b6",
            "#7b68eeb8",
            "#00fa9aba",
            "#48d1ccbc",
            "#c71585be",
            "#191970c0",
            "#f5fffac2",
            "#ffe4e1c4",
            "#ffe4b5c6",
            "#ffdeadc8",
            "#000080ca",
            "#fdf5e6cc",
            "#808000ce",
            "#6b8e23d0",
            "#ffa500d2",
            "#ff4500d4",
            "#da70d6d6",
            "#eee8aad8",
            "#98fb98da",
            "#afeeeedc",
            "#db7093de",
            "#ffefd5e0",
            "#ffdab9e2",
            "#cd853fe4",
            "#ffc0cbe6",
            "#dda0dde8",
            "#b0e0e6ea",
            "#800080ec",
            "#663399ee",
            "#ff0000f0",
            "#bc8f8ff2",
            "#4169e1f4",
            "#8b4513f6",
            "#fa8072f8",
            "#f4a460fa",
            "#2e8b57fc",
            "#fff5eefe",
            "#a0522d00",
            "#c0c0c002",
            "#87ceeb04",
            "#6a5acd06",
            "#70809008",
            "#7080900a",
            "#fffafa0c",
            "#00ff7f0e",
            "#4682b410",
            "#d2b48c12",
            "#00808014",
            "#d8bfd816",
            "#ff634718",
            "#40e0d01a",
            "#ee82ee1c",
            "#f5deb31e",
            "#ffffff20",
            "#f5f5f522",
            "#ffff0024",
            "#9acd3226",
        };

        const float_types = [_]type{ f32, f64 };
        inline for (float_types) |ft| {
            for (test_data) |td| {
                const c = try Color(ft).parse(td);
                try testing.expectEqual(null, c.name());
            }
        }
    }
}
