// SPDX-FileCopyrightText: 2025 Shun Sakai
//
// SPDX-License-Identifier: Apache-2.0 OR MIT

//! Error types for this package.

const Allocator = @import("std").mem.Allocator;

/// An error occurs while parsing a CSS color string.
pub const ParseColorError = error{
    /// The
    /// [RGB hexadecimal color string](https://www.w3.org/TR/css-color-4/#hex-notation)
    /// was invalid.
    InvalidHex,

    /// The
    /// [`rgb()` functional color notation string](https://www.w3.org/TR/css-color-4/#rgb-functions)
    /// was invalid.
    InvalidRgb,

    /// The
    /// [`hsl()` functional color notation string](https://www.w3.org/TR/css-color-4/#the-hsl-notation)
    /// was invalid.
    InvalidHsl,

    /// The
    /// [`hwb()` functional color notation string](https://www.w3.org/TR/css-color-4/#the-hwb-notation)
    /// was invalid.
    InvalidHwb,

    /// The
    /// [`oklab()` functional color notation string](https://www.w3.org/TR/css-color-4/#specifying-oklab-oklch)
    /// was invalid.
    InvalidOklab,

    /// The
    /// [`oklch()` functional color notation string](https://www.w3.org/TR/css-color-4/#specifying-oklab-oklch)
    /// was invalid.
    InvalidOklch,

    /// The string was an unsupported
    /// [color function](https://www.w3.org/TR/css-color-4/#color-functions).
    UnsupportedFunction,

    /// The string was the unrecognized
    /// [color function](https://www.w3.org/TR/css-color-4/#color-functions).
    UnknownFunction,

    /// The string was the unrecognized CSS color format.
    UnknownFormat,
} || Allocator.Error;
