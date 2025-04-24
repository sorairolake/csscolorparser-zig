<!--
SPDX-FileCopyrightText: 2025 Shun Sakai

SPDX-License-Identifier: CC-BY-4.0
-->

# csscolorparser-zig

[![CI][ci-badge]][ci-url]

**csscolorparser-zig** is a [Zig] library for parsing CSS color string as
defined in the W3C's [CSS Color Module Level 4].

## Usage

Add this package to your `build.zig.zon`:

```sh
zig fetch --save git+https://github.com/sorairolake/csscolorparser-zig.git
```

Add the following to your `build.zig`:

```zig
const csscolorparser = b.dependency("csscolorparser", .{});
exe.root_module.addImport("csscolorparser", csscolorparser.module("csscolorparser"));
```

### Documentation

To build the documentation:

```sh
zig build doc
```

The result is generated in `zig-out/doc/csscolorparser`.

If you want to preview this, run a HTTP server locally. For example:

```sh
python -m http.server -d zig-out/doc/csscolorparser
```

Then open `http://localhost:8000/` in your browser.

## Zig version

This library is compatible with Zig version 0.14.0.

## Source code

The upstream repository is available at
<https://github.com/sorairolake/csscolorparser-zig.git>.

## Changelog

Please see [CHANGELOG.adoc].

## Contributing

Please see [CONTRIBUTING.adoc].

## Acknowledgment

This library is ported from the [`csscolorparser`] crate in [Rust].

## License

Copyright (C) 2025 Shun Sakai (see [AUTHORS.adoc])

This library is distributed under the terms of either the _Apache License 2.0_
or the _MIT License_.

This project is compliant with version 3.3 of the [_REUSE Specification_]. See
copyright notices of individual files for more details on copyright and
licensing information.

[ci-badge]: https://img.shields.io/github/actions/workflow/status/sorairolake/csscolorparser-zig/CI.yaml?branch=develop&style=for-the-badge&logo=github&label=CI
[ci-url]: https://github.com/sorairolake/csscolorparser-zig/actions?query=branch%3Adevelop+workflow%3ACI++
[Zig]: https://ziglang.org/
[CSS Color Module Level 4]: https://www.w3.org/TR/css-color-4/
[CHANGELOG.adoc]: CHANGELOG.adoc
[CONTRIBUTING.adoc]: CONTRIBUTING.adoc
[`csscolorparser`]: https://crates.io/crates/csscolorparser
[Rust]: https://www.rust-lang.org/
[AUTHORS.adoc]: AUTHORS.adoc
[_REUSE Specification_]: https://reuse.software/spec-3.3/
