# Changelog

All notable changes to this project are documented in this file.

## [2.0.0] - 2026-02-13

### Added
- Added unit tests covering sorting, endpoint retention, degenerate segments, and return semantics in `/Tests/ShapeReducerTests.m`.

### Changed
- `ShapeReducer` public API now exposes only consumer-facing methods.
- `reduce:tolerance:` now always returns a new `Shape` instance.
- Internal index/sequence handling now uses `NSUInteger`.

### Fixed
- Prevented divide-by-zero in orthogonal distance calculation for degenerate line segments.
- Eliminated repeated re-sorting of points on every `points` access by sorting once per mutation.

### Breaking
- Removed internal implementation details from the public header (`_points`, `_needs_sort`, and internal recursive method).
- Raised minimum supported iOS deployment target in the podspec.
