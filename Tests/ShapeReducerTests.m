#import <XCTest/XCTest.h>
#import "ShapeReducer.h"

@interface ShapeReducerTests : XCTestCase
@end

@implementation ShapeReducerTests

- (Shape *)shapeWithCoordinates:(NSArray<NSArray<NSNumber *> *> *)coordinates {
    Shape *shape = [[[Shape alloc] init] autorelease];
    NSUInteger idx = 0;
    for (NSArray<NSNumber *> *pair in coordinates) {
        ShapePoint *point = [[[ShapePoint alloc] initWithLatitude:[pair[0] doubleValue]
                                                        longitude:[pair[1] doubleValue]
                                                         sequence:idx] autorelease];
        [shape addPoint:point];
        idx++;
    }
    return shape;
}

- (void)testReduceAlwaysReturnsNewShapeForSmallInput {
    Shape *shape = [self shapeWithCoordinates:@[@[@0.0, @0.0], @[@1.0, @1.0]]];
    ShapeReducer *reducer = [[[ShapeReducer alloc] init] autorelease];

    Shape *reduced = [reducer reduce:shape tolerance:1.0];

    XCTAssertNotNil(reduced);
    XCTAssertNotEqual(shape, reduced);
    XCTAssertEqual([[shape points] count], [[reduced points] count]);
}

- (void)testReduceAlwaysReturnsNewShapeForZeroTolerance {
    Shape *shape = [self shapeWithCoordinates:@[@[@0.0, @0.0], @[@0.5, @0.5], @[@1.0, @1.0]]];
    ShapeReducer *reducer = [[[ShapeReducer alloc] init] autorelease];

    Shape *reduced = [reducer reduce:shape tolerance:0.0];

    XCTAssertNotNil(reduced);
    XCTAssertNotEqual(shape, reduced);
    XCTAssertEqual([[shape points] count], [[reduced points] count]);
}

- (void)testReduceKeepsEndpointsWhenMiddlePointIsWithinTolerance {
    Shape *shape = [self shapeWithCoordinates:@[@[@0.0, @0.0], @[@0.5, @0.5], @[@1.0, @1.0]]];
    ShapeReducer *reducer = [[[ShapeReducer alloc] init] autorelease];

    Shape *reduced = [reducer reduce:shape tolerance:0.01];
    NSArray<ShapePoint *> *points = [reduced points];

    XCTAssertEqual([points count], (NSUInteger)2);
    XCTAssertEqualWithAccuracy(points[0].latitude, 0.0, 0.000001);
    XCTAssertEqualWithAccuracy(points[1].latitude, 1.0, 0.000001);
}

- (void)testReduceHandlesDegenerateSegment {
    Shape *shape = [self shapeWithCoordinates:@[@[@0.0, @0.0], @[@1.0, @1.0], @[@0.0, @0.0]]];
    ShapeReducer *reducer = [[[ShapeReducer alloc] init] autorelease];

    Shape *reduced = [reducer reduce:shape tolerance:0.1];

    XCTAssertNotNil(reduced);
    XCTAssertGreaterThanOrEqual([[reduced points] count], (NSUInteger)2);
}

- (void)testPointsAreSortedBySequence {
    Shape *shape = [[[Shape alloc] init] autorelease];
    [shape addPoint:[[[ShapePoint alloc] initWithLatitude:0.0 longitude:0.0 sequence:3] autorelease]];
    [shape addPoint:[[[ShapePoint alloc] initWithLatitude:0.0 longitude:0.0 sequence:1] autorelease]];
    [shape addPoint:[[[ShapePoint alloc] initWithLatitude:0.0 longitude:0.0 sequence:2] autorelease]];

    NSArray<ShapePoint *> *points = [shape points];

    XCTAssertEqual(points[0].sequence, (NSUInteger)1);
    XCTAssertEqual(points[1].sequence, (NSUInteger)2);
    XCTAssertEqual(points[2].sequence, (NSUInteger)3);
}

@end
