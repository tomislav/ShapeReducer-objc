#import <Foundation/Foundation.h>

@interface ShapePoint : NSObject {
    double latitude;
    double longitude;
    unsigned int sequence;
}

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property unsigned int sequence;

- (id)initWithLatitude:(double)aLatitude longitude:(double)aLongitude sequence:(unsigned int)aSequence;

@end

@interface Shape : NSObject {
@private
    NSMutableArray *_points;
    BOOL _needs_sort;
}

@property (nonatomic, retain) NSMutableArray *_points;
@property BOOL _needs_sort;

- (void)addPoint:(ShapePoint *)point;
- (NSArray *)points;

@end

@interface ShapeReducer : NSObject

- (Shape*)reduce:(Shape*)aShape tolerance:(double)tolerance;
- (void) douglasPeuckerReductionWithTolerance:(double)tolerance shape:(Shape*)shape outputShape:(Shape*)outputShape firstIndex:(int)first lastIndex:(int)last;
+ (double)orthogonalDistanceWithPoint:(ShapePoint *)point lineStart:(ShapePoint *)lineStart lineEnd:(ShapePoint *)lineEnd;
@end
