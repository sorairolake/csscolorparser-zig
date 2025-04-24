# SPDX-FileCopyrightText: 2025 Shun Sakai
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

# Run default recipe
_default:
    just -l

# Build a project
build:
    zig build --summary all

# Run tests
test:
    zig build test --summary all

# Run the formatter
fmt:
    zig fmt .

# Build the package documentation
doc:
    zig build doc --summary all

# Run the linter for GitHub Actions workflow files
lint-github-actions:
    actionlint -verbose

# Run the formatter for the README
fmt-readme:
    npx prettier -w README.md

# Increment the version
bump part:
    bump-my-version bump {{ part }}
