#import "MCSeasonAnalyzer.h"

@implementation MCSeasonAnalyzer
- (MCClimatePeriod *)readSeasonFromSkies:(NSArray<MCWeatherSnapshot *> *)skies {
    NSDate *limit = [NSDate dateWithTimeIntervalSinceNow:-90 * 24 * 3600];
    NSMutableArray *slice = [NSMutableArray array];
    NSInteger total = 0, rough = 0, sunny = 0;
    for (MCWeatherSnapshot *sky in skies) {
        if ([sky.day compare:limit] != NSOrderedAscending) {
            [slice addObject:sky];
            total += sky.weight;
            if (sky.kind == MCWeatherKindRainstorm || sky.kind == MCWeatherKindThunder) rough++;
            if (sky.kind == MCWeatherKindSunny) sunny++;
        }
    }
    if (slice.count == 0) return [MCClimatePeriod periodWithSeason:@"Uncharted Spring" climate:@"Awaiting first signal" temperature:68 calm:0 count:0 zone:@"Blank Sky"];
    NSInteger avg = total / slice.count;
    NSString *season = avg >= 82 ? @"Restorative Spring" : avg >= 67 ? @"Active Summer" : avg >= 48 ? @"Steady Autumn" : @"Low Tide Winter";
    NSString *climate = avg >= 78 ? @"Clear and resilient" : avg >= 60 ? @"Mild stable pattern" : avg >= 42 ? @"Pressure mixed belt" : @"Heavy storm corridor";
    NSString *zone = rough > sunny ? @"Pressure Zone" : sunny > slice.count / 2 ? @"Clear Region" : avg > 60 ? @"Calm Area" : @"Anxiety Belt";
    return [MCClimatePeriod periodWithSeason:season climate:climate temperature:avg calm:MAX(0, 100 - rough * 9) count:slice.count zone:zone];
}
@end
