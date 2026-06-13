#import "MCWeatherSnapshot.h"

NSArray<NSNumber *> *MCWeatherAllKinds(void) {
    return @[@(MCWeatherKindSunny), @(MCWeatherKindCloudy), @(MCWeatherKindOvercast), @(MCWeatherKindDrizzle), @(MCWeatherKindRainstorm), @(MCWeatherKindThunder), @(MCWeatherKindWind), @(MCWeatherKindSnow)];
}

NSString *MCWeatherKindTitle(MCWeatherKind kind) {
    switch (kind) {
        case MCWeatherKindSunny: return @"Sunny";
        case MCWeatherKindCloudy: return @"Cloudy";
        case MCWeatherKindOvercast: return @"Overcast";
        case MCWeatherKindDrizzle: return @"Drizzle";
        case MCWeatherKindRainstorm: return @"Rainstorm";
        case MCWeatherKindThunder: return @"Thunder";
        case MCWeatherKindWind: return @"Wind";
        case MCWeatherKindSnow: return @"Snow";
    }
}

NSString *MCWeatherKindGlyph(MCWeatherKind kind) {
    switch (kind) {
        case MCWeatherKindSunny: return @"☀️";
        case MCWeatherKindCloudy: return @"☁️";
        case MCWeatherKindOvercast: return @"🌫";
        case MCWeatherKindDrizzle: return @"🌦";
        case MCWeatherKindRainstorm: return @"🌧";
        case MCWeatherKindThunder: return @"⛈";
        case MCWeatherKindWind: return @"🌪";
        case MCWeatherKindSnow: return @"❄️";
    }
}

@implementation MCWeatherSnapshot
+ (instancetype)sky:(MCWeatherKind)kind force:(NSInteger)force signals:(NSArray<NSString *> *)signals memo:(NSString *)memo day:(NSDate *)day {
    MCWeatherSnapshot *sky = [MCWeatherSnapshot new];
    sky.kind = kind;
    sky.force = MAX(1, MIN(10, force));
    sky.signals = signals ?: @[];
    sky.memo = memo ?: @"";
    sky.day = day ?: [NSDate date];
    return sky;
}

+ (instancetype)fromArchive:(NSDictionary *)archive {
    NSTimeInterval time = [archive[@"day"] doubleValue];
    return [self sky:[archive[@"kind"] integerValue]
              force:[archive[@"force"] integerValue]
            signals:[archive[@"signals"] isKindOfClass:NSArray.class] ? archive[@"signals"] : @[]
               memo:[archive[@"memo"] isKindOfClass:NSString.class] ? archive[@"memo"] : @""
                day:[NSDate dateWithTimeIntervalSince1970:time]];
}

- (NSDictionary *)archive {
    return @{@"kind": @(self.kind), @"force": @(self.force), @"signals": self.signals ?: @[], @"memo": self.memo ?: @"", @"day": @([self.day timeIntervalSince1970])};
}

- (NSString *)title { return MCWeatherKindTitle(self.kind); }
- (NSString *)glyph { return MCWeatherKindGlyph(self.kind); }

- (NSInteger)weight {
    switch (self.kind) {
        case MCWeatherKindSunny: return 92;
        case MCWeatherKindCloudy: return 76;
        case MCWeatherKindOvercast: return 62;
        case MCWeatherKindDrizzle: return 52;
        case MCWeatherKindWind: return 48;
        case MCWeatherKindSnow: return 44;
        case MCWeatherKindRainstorm: return 30;
        case MCWeatherKindThunder: return 20;
    }
}
@end
