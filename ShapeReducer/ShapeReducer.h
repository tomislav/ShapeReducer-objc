#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShapePoint : NSObject
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) NSUInteger sequence;

- (instancetype)initWithLatitude:(double)aLatitude
                       longitude:(double)aLongitude
                        sequence:(NSUInteger)aSequence NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface Shape : NSObject

- (void)addPoint:(ShapePoint *)point;
- (NSArray<ShapePoint *> *)points;

@end

@interface ShapeReducer : NSObject

- (nullable Shape *)reduce:(nullable Shape *)aShape tolerance:(double)tolerance;
@end

NS_ASSUME_NONNULL_END
