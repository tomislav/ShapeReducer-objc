#import "ShapeReducer.h"
#import <float.h>
#import <math.h>

@interface Shape ()
@property (nonatomic, retain) NSMutableArray<ShapePoint *> *pointsStorage;
@property (nonatomic, assign) BOOL needsSort;
@end

@interface ShapeReducer ()
- (void)douglasPeuckerReductionWithTolerance:(double)tolerance
                                      points:(NSArray<ShapePoint *> *)points
                                 outputShape:(Shape *)outputShape
                                  firstIndex:(NSUInteger)first
                                   lastIndex:(NSUInteger)last;
+ (double)orthogonalDistanceWithPoint:(ShapePoint *)point
                            lineStart:(ShapePoint *)lineStart
                              lineEnd:(ShapePoint *)lineEnd;
@end

@implementation ShapePoint

@synthesize latitude, longitude, sequence;

- (instancetype)initWithLatitude:(double)aLatitude
                       longitude:(double)aLongitude
                        sequence:(NSUInteger)aSequence {
    if ((self = [super init])) {
        self.latitude = aLatitude;
        self.longitude = aLongitude;
        self.sequence = aSequence;
    }
    return self;
}

@end

@implementation Shape

@synthesize pointsStorage = _pointsStorage;
@synthesize needsSort = _needsSort;

- (instancetype)init {
    if ((self = [super init])) {
        _pointsStorage = [[NSMutableArray alloc] init];
        _needsSort = NO;
    }
    return self;
}

- (void)addPoint:(ShapePoint *)point {
    if (point == nil) {
        return;
    }

    [self.pointsStorage addObject:point];
    self.needsSort = YES;
}

- (NSArray<ShapePoint *> *)points {
    if (self.needsSort) {
        [self.pointsStorage sortUsingComparator:^NSComparisonResult(ShapePoint *obj1, ShapePoint *obj2) {
            if (obj1.sequence > obj2.sequence) {
                return NSOrderedDescending;
            }
            if (obj1.sequence < obj2.sequence) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
        self.needsSort = NO;
    }
    return self.pointsStorage;
}

- (void)dealloc {
    [_pointsStorage release];
    [super dealloc];
}

@end


@implementation ShapeReducer

- (instancetype)init {
    self = [super init];
    return self;
}

- (nullable Shape *)reduce:(Shape *)aShape tolerance:(double)tolerance {
    if (aShape == nil) {
        return nil;
    }

    NSArray<ShapePoint *> *points = [aShape points];
    Shape *newShape = [[[Shape alloc] init] autorelease];

    if ([points count] == 0) {
        return newShape;
    }

    if (tolerance <= 0 || [points count] < 3) {
        for (ShapePoint *point in points) {
            [newShape addPoint:point];
        }
        [newShape points];
        return newShape;
    }

    [newShape addPoint:[points objectAtIndex:0]];
    [newShape addPoint:[points lastObject]];

    [self douglasPeuckerReductionWithTolerance:tolerance
                                        points:points
                                   outputShape:newShape
                                    firstIndex:0
                                     lastIndex:[points count] - 1];

    [newShape points];
    return newShape;
}

- (void)douglasPeuckerReductionWithTolerance:(double)tolerance
                                      points:(NSArray<ShapePoint *> *)points
                                 outputShape:(Shape *)outputShape
                                  firstIndex:(NSUInteger)first
                                   lastIndex:(NSUInteger)last {
    if (last <= first + 1) {
        return;
    }

    double maxDistance = 0.0;
    NSUInteger indexFarthest = NSNotFound;
    ShapePoint *firstPoint = [points objectAtIndex:first];
    ShapePoint *lastPoint = [points objectAtIndex:last];

    for (NSUInteger idx = first + 1; idx < last; idx++) {
        ShapePoint *point = [points objectAtIndex:idx];
        double distance = [ShapeReducer orthogonalDistanceWithPoint:point
                                                          lineStart:firstPoint
                                                            lineEnd:lastPoint];

        if (distance > maxDistance) {
            maxDistance = distance;
            indexFarthest = idx;
        }
    }

    if (maxDistance > tolerance && indexFarthest != NSNotFound) {
        [outputShape addPoint:[points objectAtIndex:indexFarthest]];

        [self douglasPeuckerReductionWithTolerance:tolerance
                                            points:points
                                       outputShape:outputShape
                                        firstIndex:first
                                         lastIndex:indexFarthest];

        [self douglasPeuckerReductionWithTolerance:tolerance
                                            points:points
                                       outputShape:outputShape
                                        firstIndex:indexFarthest
                                         lastIndex:last];
    }
}

+ (double)orthogonalDistanceWithPoint:(ShapePoint *)point
                            lineStart:(ShapePoint *)lineStart
                              lineEnd:(ShapePoint *)lineEnd {
    double area = ABS((lineStart.latitude * lineEnd.longitude
                       + lineEnd.latitude * point.longitude
                       + point.latitude * lineStart.longitude
                       - lineEnd.latitude * lineStart.longitude
                       - point.latitude * lineEnd.longitude
                       - lineStart.latitude * point.longitude) / 2.0);

    double bottom = hypot(lineStart.latitude - lineEnd.latitude,
                          lineStart.longitude - lineEnd.longitude);
    if (bottom <= DBL_EPSILON) {
        // Degenerate segment: distance to the single endpoint is the safest fallback.
        return hypot(point.latitude - lineStart.latitude,
                     point.longitude - lineStart.longitude);
    }

    double height = (area / bottom) * 2.0;
    return height;
}

@end
