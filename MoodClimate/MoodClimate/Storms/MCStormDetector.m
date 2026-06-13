#import "MCStormDetector.h"

@implementation MCStormDetector
- (NSArray<MCWeatherSnapshot *> *)oldestFirst:(NSArray<MCWeatherSnapshot *> *)skies {
    return [skies sortedArrayUsingComparator:^NSComparisonResult(MCWeatherSnapshot *a, MCWeatherSnapshot *b) { return [a.day compare:b.day]; }];
}

- (NSArray<MCStormEvent *> *)stormsInSkies:(NSArray<MCWeatherSnapshot *> *)skies {
    NSMutableArray *events = [NSMutableArray array];
    NSMutableArray *run = [NSMutableArray array];
    for (MCWeatherSnapshot *sky in [self oldestFirst:skies]) {
        BOOL hard = sky.kind == MCWeatherKindRainstorm || sky.kind == MCWeatherKindThunder;
        if (hard) { if (![self run:run touches:sky]) [self drainStormRun:run into:events]; [run addObject:sky]; } else [self drainStormRun:run into:events];
    }
    [self drainStormRun:run into:events];
    return [[events reverseObjectEnumerator] allObjects];
}

- (BOOL)run:(NSArray *)run touches:(MCWeatherSnapshot *)sky {
    if (!run.count) return YES;
    MCWeatherSnapshot *last = run.lastObject;
    NSDateComponents *gap = [NSCalendar.currentCalendar components:NSCalendarUnitDay fromDate:[NSCalendar.currentCalendar startOfDayForDate:last.day] toDate:[NSCalendar.currentCalendar startOfDayForDate:sky.day] options:0];
    return gap.day == 1;
}

- (void)drainStormRun:(NSMutableArray *)run into:(NSMutableArray *)events {
    if (run.count >= 7) {
        MCWeatherSnapshot *first = run.firstObject, *last = run.lastObject;
        NSString *name = run.count >= 14 ? @"Long Thunder System" : @"Rainstorm Front";
        NSString *origin = first.signals.count ? [first.signals componentsJoinedByString:@", "] : @"Unknown origin";
        [events addObject:[MCStormEvent event:name start:first.day end:last.day span:run.count origin:origin]];
    }
    [run removeAllObjects];
}

- (NSArray<MCSunnyEpoch *> *)sunnyEpochsInSkies:(NSArray<MCWeatherSnapshot *> *)skies {
    NSMutableArray *epochs = [NSMutableArray array];
    NSMutableArray *run = [NSMutableArray array];
    for (MCWeatherSnapshot *sky in [self oldestFirst:skies]) {
        if (sky.kind == MCWeatherKindSunny) { if (![self run:run touches:sky]) [self drainSunnyRun:run into:epochs]; [run addObject:sky]; } else [self drainSunnyRun:run into:epochs];
    }
    [self drainSunnyRun:run into:epochs];
    return [[epochs reverseObjectEnumerator] allObjects];
}

- (void)drainSunnyRun:(NSMutableArray *)run into:(NSMutableArray *)epochs {
    if (run.count >= 30) {
        MCWeatherSnapshot *first = run.firstObject, *last = run.lastObject;
        [epochs addObject:[MCSunnyEpoch epochFrom:first.day to:last.day span:run.count]];
    }
    [run removeAllObjects];
}
@end
