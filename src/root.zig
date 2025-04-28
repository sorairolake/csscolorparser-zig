// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

//! The `csscolorparser` package is a library for parsing CSS color string as
//! defined in the W3C's
//! [CSS Color Module Level 4](https://www.w3.org/TR/css-color-4/).

pub const Color = @import("color.zig").Color;
pub const ParseColorError = @import("errors.zig").ParseColorError;
pub const named_colors = @import("named_colors.zig").named_colors;

test {
    const testing = @import("std").testing;

    testing.refAllDeclsRecursive(@This());
}
