#import <Foundation/Foundation.h>

@interface ShapePoint : NSObject {
}

@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;

- (id)initWithLatitude:(double)aLatitude longitude:(double)aLongitude;

@end

@interface Shape : NSObject {
@private
    NSMutableArray *_points;
}

@property (nonatomic, strong) NSMutableArray *_points;

- (void)addPoint:(ShapePoint *)point;
- (NSArray *)points;

@end

@interface ShapeReducer : NSObject

- (Shape*)reduce:(Shape*)aShape tolerance:(double)tolerance;
- (void) douglasPeuckerReductionWithTolerance:(double)tolerance shape:(Shape*)shape outputShape:(Shape*)outputShape firstIndex:(NSUInteger)first lastIndex:(NSUInteger)last;
+ (double)orthogonalDistanceWithPoint:(ShapePoint *)point lineStart:(ShapePoint *)lineStart lineEnd:(ShapePoint *)lineEnd;
@end
