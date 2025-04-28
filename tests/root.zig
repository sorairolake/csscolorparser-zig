// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

test {
    const testing = @import("std").testing;

    _ = @import("chrome_android.zig");
    _ = @import("chromium.zig");
    _ = @import("color.zig");
    _ = @import("firefox.zig");
    _ = @import("named_colors.zig");
    _ = @import("parser.zig");

    testing.refAllDeclsRecursive(@This());
}
