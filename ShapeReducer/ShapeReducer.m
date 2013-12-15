#import "ShapeReducer.h"

@implementation ShapePoint

@synthesize latitude, longitude, sequence;

- (id)initWithLatitude:(double)aLatitude longitude:(double)aLongitude sequence:(unsigned int)aSequence
{
    if ((self = [super init])) {
        self.latitude = aLatitude;
        self.longitude = aLongitude;
        self.sequence = aSequence;
    }
    return self;
}

- (id)init
{
    self = [super init];
    return self;
}

@end

@implementation Shape

@synthesize _points, _needs_sort, _needs_region, _region;

- (id)init
{
    if ((self = [super init])) {
        _points = [[NSMutableArray alloc] init];
        _needs_sort = NO;
        _needs_region = NO;
    }
    return self;
}

- (void)addPoint:(ShapePoint *)point
{
    [_points addObject:point];
    _needs_sort = YES;
    _needs_region = YES;
}

- (NSArray *)points
{
    if (_needs_sort) {
        NSComparisonResult (^sortBlock)(id, id) = ^(id obj1, id obj2) {
            if ([obj1 sequence] > [obj2 sequence]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([obj1 sequence] < [obj2 sequence]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        NSArray *sortedPoints = [_points sortedArrayUsingComparator:sortBlock];
        _needs_sort = NO;
        _points = [sortedPoints copy];
    }
    return _points;
}

- (MKCoordinateRegion)region
{
    if (_needs_region) {
        CLLocationDegrees latDelta, lonDelta;
        double minLat = [(ShapePoint *)_points[0] latitude];
        double minLon = [(ShapePoint *)_points[0] longitude];
        double maxLat = [(ShapePoint *)_points[0] latitude];
        double maxLon = [(ShapePoint *)_points[0] longitude];
        for (ShapePoint * p in _points) {
            if (p.latitude > maxLat)
                maxLat = p.latitude;
            if (p.latitude < minLat)
                minLat = p.latitude;
            if (p.longitude > maxLon)
                maxLon = p.longitude;
            if (p.longitude < minLon)
                minLon = p.longitude;
        }
        latDelta = (CLLocationDegrees)(maxLat - minLat);
        lonDelta = (CLLocationDegrees)(maxLon - minLon);
        MKCoordinateSpan span = MKCoordinateSpanMake(latDelta * 1.75, lonDelta * 1.5);
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(maxLat - (latDelta / 2.0), maxLon - (lonDelta / 2.0));
        _region = MKCoordinateRegionMake(center, span);
        _needs_region = NO;
    }
    return _region;
}

/** List of coordinates, for use in methods that don't accept NSArray, such as MKPolyline polylineWithCoordinates */
- (CLLocationCoordinate2D *)coordinates {
    // Points need to be sorted
    NSArray *points = self.points;
    CLLocationCoordinate2D *coordinateArray = malloc(sizeof(CLLocationCoordinate2D) * points.count);
    int i = 0;
    for (ShapePoint *p in points) {
        coordinateArray[i] = CLLocationCoordinate2DMake(p.latitude, p.longitude);
        i++;
    }
    return coordinateArray;
}


@end


@implementation ShapeReducer

- (id)init
{
    self = [super init];
    return self;
}

- (Shape*)reduce:(Shape*)aShape tolerance:(double)tolerance
{
    if (tolerance <= 0 || [aShape.points count] < 3) {
        return aShape;
    }
    
    NSArray *points = [aShape points];
    Shape *newShape = [[Shape alloc] init];
    
    [newShape addPoint:[points objectAtIndex:0]];
    [newShape addPoint:[points lastObject]];
    
    [self douglasPeuckerReductionWithTolerance:tolerance shape:aShape
                                   outputShape:newShape firstIndex:0 lastIndex:[points count]-1];
    
    return newShape;
    
}

- (void) douglasPeuckerReductionWithTolerance:(double)tolerance shape:(Shape*)shape outputShape:(Shape*)outputShape firstIndex:(int)first lastIndex:(int)last
{
    if (last <= first + 1) {
        return;
    }
    
    NSArray *points = [shape points];
    
    double distance, maxDistance = 0.0;
    int indexFarthest = 0;
    
    ShapePoint *firstPoint = [points objectAtIndex:first];
    ShapePoint *lastPoint = [points objectAtIndex:last];
    
    for (int idx=first+1; idx<last; idx++) {
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
        [outputShape addPoint:[points objectAtIndex:indexFarthest]];
        
        [self douglasPeuckerReductionWithTolerance:tolerance shape:shape
                                       outputShape:outputShape firstIndex:first lastIndex:indexFarthest];
        
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