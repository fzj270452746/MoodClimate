#import "MCChronicleVault.h"

static NSString * const MCSkiesKey = @"mc.skies.v1";
static NSString * const MCLifeMarksKey = @"mc.lifeMarks.v1";
static NSString * const MCReviewsKey = @"mc.reviews.v1";

@implementation MCChronicleVault
- (NSArray<MCWeatherSnapshot *> *)skies {
    NSArray *raw = [[NSUserDefaults standardUserDefaults] arrayForKey:MCSkiesKey] ?: @[];
    NSMutableArray *out = [NSMutableArray array];
    for (NSDictionary *box in raw) if ([box isKindOfClass:NSDictionary.class]) [out addObject:[MCWeatherSnapshot fromArchive:box]];
    [out sortUsingComparator:^NSComparisonResult(MCWeatherSnapshot *a, MCWeatherSnapshot *b) { return [b.day compare:a.day]; }];
    return out;
}

- (NSArray<NSDictionary *> *)lifeMarks {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:MCLifeMarksKey] ?: @[];
}

- (NSArray<NSDictionary *> *)reviews {
    return [[NSUserDefaults standardUserDefaults] arrayForKey:MCReviewsKey] ?: @[];
}

- (void)placeSky:(MCWeatherSnapshot *)sky {
    NSCalendar *cal = NSCalendar.currentCalendar;
    NSMutableArray *raw = [NSMutableArray array];
    for (MCWeatherSnapshot *old in [self skies]) {
        if (![cal isDate:old.day inSameDayAsDate:sky.day]) [raw addObject:[old archive]];
    }
    [raw addObject:[sky archive]];
    [[NSUserDefaults standardUserDefaults] setObject:raw forKey:MCSkiesKey];
}

- (void)removeSkyOnDay:(NSDate *)day {
    NSCalendar *cal = NSCalendar.currentCalendar;
    NSMutableArray *raw = [NSMutableArray array];
    for (MCWeatherSnapshot *old in [self skies]) {
        if (![cal isDate:old.day inSameDayAsDate:day ?: NSDate.date]) [raw addObject:[old archive]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:raw forKey:MCSkiesKey];
}

- (void)placeLifeMark:(NSString *)title detail:(NSString *)detail day:(NSDate *)day {
    NSMutableArray *marks = [[self lifeMarks] mutableCopy];
    [marks insertObject:@{@"title": title ?: @"Life event", @"detail": detail ?: @"", @"day": @([(day ?: NSDate.date) timeIntervalSince1970])} atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:marks forKey:MCLifeMarksKey];
}

- (void)placeReview:(NSString *)title body:(NSString *)body day:(NSDate *)day {
    NSMutableArray *reviews = [[self reviews] mutableCopy];
    [reviews insertObject:@{@"title": title ?: @"Weekly Review", @"body": body ?: @"", @"day": @([(day ?: NSDate.date) timeIntervalSince1970])} atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:reviews forKey:MCReviewsKey];
}

- (void)clearAll {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MCSkiesKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MCLifeMarksKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MCReviewsKey];
}
@end
