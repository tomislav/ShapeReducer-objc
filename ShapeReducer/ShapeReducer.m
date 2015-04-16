#import "ShapeReducer.h"

@implementation ShapePoint

- (id)initWithLatitude:(double)aLatitude longitude:(double)aLongitude {
	if ((self = [super init])) { 
		_latitude = aLatitude;
		_longitude = aLongitude;
	}
	return self;
}

@end

@implementation Shape

@synthesize _points;

- (id)init
{
	if ((self = [super init])) { 
        _points = [[NSMutableArray alloc] init];
	}
    return self;
}

- (void)addPoint:(ShapePoint *)point {
    [_points addObject:point];
}

- (NSArray *)points {
    return _points;
}

- (void)dealloc {
    _points = nil;
}

@end


@implementation ShapeReducer

- (Shape*)reduce:(Shape*)aShape tolerance:(double)tolerance {
    if (tolerance <= 0 || [aShape.points count] < 3) {
        return aShape;
    }
    
    NSArray *points = aShape.points;
    Shape *newShape = [[Shape alloc] init];
    
    [newShape addPoint:points.firstObject];

    [self douglasPeuckerReductionWithTolerance:tolerance shape:aShape
                               outputShape:newShape firstIndex:0 lastIndex:[points count]-1];
    [newShape addPoint:points.lastObject];
    
    return newShape;
}

- (void) douglasPeuckerReductionWithTolerance:(double)tolerance shape:(Shape*)shape outputShape:(Shape*)outputShape firstIndex:(NSUInteger)first lastIndex:(NSUInteger)last {
    if (last <= first + 1) {
        return;
    }
        
    NSArray *points = [shape points];
    
    double distance, maxDistance = 0.0;
    NSUInteger indexFarthest = 0;
    
    ShapePoint *firstPoint = [points objectAtIndex:first];
    ShapePoint *lastPoint = [points objectAtIndex:last];
    
    for (NSUInteger idx=first+1; idx<last; idx++) {
        ShapePoint *point = [points objectAtIndex:idx];
        
        distance = [ShapeReducer orthogonalDistanceWithPoint:point lineStart:firstPoint lineEnd:lastPoint];
        
        // if the current distance is larger then the other distances
        if (distance>maxDistance) {
            maxDistance=distance;
            indexFarthest=idx;
        }
    }
        
    if (maxDistance>tolerance && indexFarthest!=0) {
        //add index of Point to list of Points to keep
        [self douglasPeuckerReductionWithTolerance:tolerance shape:shape
                                   outputShape:outputShape firstIndex:first lastIndex:indexFarthest];
        [outputShape addPoint:[points objectAtIndex:indexFarthest]];
        [self douglasPeuckerReductionWithTolerance:tolerance shape:shape outputShape:outputShape firstIndex:indexFarthest lastIndex:last];
    }
}

+ (double)orthogonalDistanceWithPoint:(ShapePoint *)point lineStart:(ShapePoint *)lineStart lineEnd:(ShapePoint *)lineEnd
{
    double area = 0.0, bottom = 0.0, height = 0.0;
    area = ABS(
                      (
                       lineStart.latitude * lineEnd.longitude
                       + lineEnd.latitude * point.longitude
                       + point.latitude * lineStart.longitude
                       - lineEnd.latitude * lineStart.longitude
                       - point.latitude * lineEnd.longitude
                       - lineStart.latitude * point.longitude
                       ) / 2.0);
     
    bottom = sqrt(pow(lineStart.latitude - lineEnd.latitude, 2) +
                         pow(lineStart.longitude - lineEnd.longitude, 2));

    height = area / bottom * 2.0;
    
    return height;
}


@end
