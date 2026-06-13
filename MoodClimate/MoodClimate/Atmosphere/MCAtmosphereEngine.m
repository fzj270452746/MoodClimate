#import "MCAtmosphereEngine.h"

NSString * const MCClimateShiftEvent = @"MCClimateShiftEvent";

@implementation MCAtmosphereEngine
- (instancetype)initWithAtlas:(MCClimateAtlas *)atlas {
    self = [super init];
    if (self) _atlas = atlas;
    return self;
}
- (void)observeWeather:(MCWeatherKind)kind force:(NSInteger)force signals:(NSArray<NSString *> *)signals memo:(NSString *)memo {
    [self observeWeather:kind force:force signals:signals memo:memo day:NSDate.date];
}
- (void)observeWeather:(MCWeatherKind)kind force:(NSInteger)force signals:(NSArray<NSString *> *)signals memo:(NSString *)memo day:(NSDate *)day {
    [self.atlas.vault placeSky:[MCWeatherSnapshot sky:kind force:force signals:signals memo:memo day:day ?: NSDate.date]];
    [NSNotificationCenter.defaultCenter postNotificationName:MCClimateShiftEvent object:self];
}
- (void)removeWeatherOnDay:(NSDate *)day {
    [self.atlas.vault removeSkyOnDay:day ?: NSDate.date];
    [NSNotificationCenter.defaultCenter postNotificationName:MCClimateShiftEvent object:self];
}
- (void)markLife:(NSString *)title detail:(NSString *)detail {
    [self markLife:title detail:detail day:NSDate.date];
}
- (void)markLife:(NSString *)title detail:(NSString *)detail day:(NSDate *)day {
    [self.atlas.vault placeLifeMark:title detail:detail day:day ?: NSDate.date];
    [NSNotificationCenter.defaultCenter postNotificationName:MCClimateShiftEvent object:self];
}
- (void)saveReview:(NSString *)title body:(NSString *)body {
    [self.atlas.vault placeReview:title body:body day:NSDate.date];
    [NSNotificationCenter.defaultCenter postNotificationName:MCClimateShiftEvent object:self];
}
- (void)clearArchive {
    [self.atlas.vault clearAll];
    [NSNotificationCenter.defaultCenter postNotificationName:MCClimateShiftEvent object:self];
}
@end
