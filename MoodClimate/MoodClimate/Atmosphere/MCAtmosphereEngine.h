#import <Foundation/Foundation.h>
#import "MCClimateAtlas.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const MCClimateShiftEvent;

@interface MCAtmosphereEngine : NSObject
@property (nonatomic, strong, readonly) MCClimateAtlas *atlas;
- (instancetype)initWithAtlas:(MCClimateAtlas *)atlas;
- (void)observeWeather:(MCWeatherKind)kind force:(NSInteger)force signals:(NSArray<NSString *> *)signals memo:(NSString *)memo;
- (void)observeWeather:(MCWeatherKind)kind force:(NSInteger)force signals:(NSArray<NSString *> *)signals memo:(NSString *)memo day:(NSDate *)day;
- (void)removeWeatherOnDay:(NSDate *)day;
- (void)markLife:(NSString *)title detail:(NSString *)detail;
- (void)markLife:(NSString *)title detail:(NSString *)detail day:(NSDate *)day;
- (void)saveReview:(NSString *)title body:(NSString *)body;
- (void)clearArchive;
@end

NS_ASSUME_NONNULL_END
