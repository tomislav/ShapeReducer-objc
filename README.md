# ShapeReducer (Objective-C)

Path optimization using the Ramer-Douglas-Peucker line simplification algorithm.

Written by Tomislav Filipčić <tomislav@me.com>. Ported from PHP port by Quentin Zervaas <http://www.phpriot.com/articles/reducing-map-path-douglas-peucker-algorithm>

## Installation

Add to your `Podfile`:

```ruby
pod 'ShapeReducer', '~> 2.0'
```

Then run:

```bash
pod install
```

## Usage

```objc
#import <ShapeReducer/ShapeReducer.h>

Shape *shape = [[[Shape alloc] init] autorelease];
[shape addPoint:[[[ShapePoint alloc] initWithLatitude:45.0000 longitude:15.0000 sequence:0] autorelease]];
[shape addPoint:[[[ShapePoint alloc] initWithLatitude:45.0100 longitude:15.0100 sequence:1] autorelease]];
[shape addPoint:[[[ShapePoint alloc] initWithLatitude:45.0200 longitude:15.0200 sequence:2] autorelease]];

ShapeReducer *reducer = [[[ShapeReducer alloc] init] autorelease];
Shape *reduced = [reducer reduce:shape tolerance:0.001];
NSArray<ShapePoint *> *points = [reduced points];
```

## Tolerance Units

`tolerance` is measured in the same units as your input coordinates.

- If you pass latitude/longitude degrees, tolerance is in degrees.
- If you pass projected coordinates (for example meters), tolerance is in those units.

## Behavior Notes

- `reduce:tolerance:` always returns a new `Shape` instance.
- Start and end points are always preserved for simplifiable paths.
- Point ordering is based on each point's `sequence`.

## Reference

[Ramer-Douglas-Peucker algorithm](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm)
