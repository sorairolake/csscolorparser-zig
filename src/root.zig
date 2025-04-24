// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

//! The `csscolorparser` package is a library for parsing CSS color string as
//! defined in the W3C's
//! [CSS Color Module Level 4](https://www.w3.org/TR/css-color-4/).

const std = @import("std");
const testing = std.testing;

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
