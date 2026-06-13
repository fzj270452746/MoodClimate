#import "MCReportForge.h"

@implementation MCReportForge
- (NSArray<MCWeatherSnapshot *> *)skies:(NSArray<MCWeatherSnapshot *> *)skies since:(NSInteger)days {
    NSDate *limit = [NSDate dateWithTimeIntervalSinceNow:-days * 24 * 3600];
    NSMutableArray *out = [NSMutableArray array];
    for (MCWeatherSnapshot *sky in skies) if ([sky.day compare:limit] != NSOrderedAscending) [out addObject:sky];
    return out;
}

- (NSInteger)average:(NSArray<MCWeatherSnapshot *> *)skies {
    if (!skies.count) return 0;
    NSInteger total = 0;
    for (MCWeatherSnapshot *sky in skies) total += sky.weight;
    return total / skies.count;
}

- (NSInteger)rough:(NSArray<MCWeatherSnapshot *> *)skies {
    NSInteger count = 0;
    for (MCWeatherSnapshot *sky in skies) if (sky.kind == MCWeatherKindRainstorm || sky.kind == MCWeatherKindThunder) count++;
    return count;
}

- (NSInteger)clear:(NSArray<MCWeatherSnapshot *> *)skies {
    NSInteger count = 0;
    for (MCWeatherSnapshot *sky in skies) if (sky.kind == MCWeatherKindSunny || sky.kind == MCWeatherKindCloudy) count++;
    return count;
}

- (NSString *)movementFrom:(NSInteger)base to:(NSInteger)now {
    if (!base || !now) return @"insufficient data";
    NSInteger delta = now - base;
    if (delta > 8) return [NSString stringWithFormat:@"warming +%ld°", (long)delta];
    if (delta < -8) return [NSString stringWithFormat:@"cooling %ld°", (long)delta];
    return @"stable range";
}

- (NSString *)markdownForSkies:(NSArray<MCWeatherSnapshot *> *)skies climate:(MCClimatePeriod *)climate storms:(NSArray<MCStormEvent *> *)storms sunny:(NSArray<MCSunnyEpoch *> *)sunny {
    NSInteger clear = 0, rough = 0, total = 0;
    NSMutableDictionary *weather = [NSMutableDictionary dictionary]; NSMutableDictionary *signals = [NSMutableDictionary dictionary];
    for (MCWeatherSnapshot *sky in skies) {
        if (sky.kind == MCWeatherKindSunny) clear++; if (sky.kind == MCWeatherKindRainstorm || sky.kind == MCWeatherKindThunder) rough++; total += sky.weight;
        NSString *title = sky.title; weather[title] = @([weather[title] integerValue] + 1);
        for (NSString *word in sky.signals) signals[word] = @([signals[word] integerValue] + 1);
    }
    NSInteger clearRate = skies.count ? clear * 100 / skies.count : 0;
    NSInteger longestClear = 0, longestStorm = 0;
    for (MCSunnyEpoch *epoch in sunny) longestClear = MAX(longestClear, epoch.span);
    for (MCStormEvent *storm in storms) longestStorm = MAX(longestStorm, storm.span);
    NSArray *week = [self skies:skies since:7];
    NSArray *twoWeeks = [self skies:skies since:14];
    NSArray *month = [self skies:skies since:30];
    NSInteger weekTemp = [self average:week];
    NSInteger monthTemp = [self average:month];
    NSMutableString *text = [NSMutableString stringWithFormat:@"# Mood Climate Report\n\nMood Climate observes long-term emotional weather. It does not diagnose health conditions and keeps all records on device unless exported by the user.\n\n## Climate Center\n\n- Season: %@\n- Climate: %@\n- Temperature: %ld°\n- Map zone: %@\n- Observed skies: %lu\n\n## Weekly / Monthly Motion\n\n- 7-day temperature: %ld°\n- 14-day temperature: %ld°\n- 30-day baseline: %ld°\n- Movement: %@\n- 14-day clear skies: %ld\n- 14-day rough skies: %ld\n\n## Annual Signals\n\n- Clear sky ratio: %ld%%\n- Storm count: %lu\n- Longest clear epoch: %ld days\n- Longest low valley: %ld days\n- Recovery ability: %ld/100\n- Climate stability: %ld/100\n- Rough weather ratio: %ld%%\n\n", climate.seasonName, climate.climateName, (long)climate.temperature, climate.mapZone, (unsigned long)skies.count, (long)weekTemp, (long)[self average:twoWeeks], (long)monthTemp, [self movementFrom:monthTemp to:weekTemp], (long)[self clear:twoWeeks], (long)[self rough:twoWeeks], (long)clearRate, (unsigned long)storms.count, (long)longestClear, (long)longestStorm, (long)climate.calmIndex, (long)MAX(0, climate.temperature - storms.count * 5), skies.count ? rough * 100 / skies.count : 0];
    [text appendString:@"## Weather Library\n\n"];
    for (NSNumber *kind in MCWeatherAllKinds()) { NSString *title = MCWeatherKindTitle(kind.integerValue); [text appendFormat:@"- %@ %@: %@\n", MCWeatherKindGlyph(kind.integerValue), title, weather[title] ?: @0]; }
    [text appendString:@"\n## Strongest Signal Belts\n\n"];
    NSArray *keys = [signals keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) { return [b compare:a]; }];
    if (!keys.count) [text appendString:@"- No signal belt yet\n"];
    for (NSInteger i = 0; i < MIN(6, keys.count); i++) [text appendFormat:@"- %@: %@\n", keys[i], signals[keys[i]]];
    [text appendString:@"\n## Storm Archive\n\n"];
    if (!storms.count) [text appendString:@"- No storm event filed yet\n"];
    for (MCStormEvent *storm in storms) [text appendFormat:@"- %@ · %ld days · origin %@\n", storm.name, (long)storm.span, storm.origin];
    [text appendString:@"\n## Clear Sky Memorial\n\n"];
    if (!sunny.count) [text appendString:@"- No clear epoch filed yet\n"];
    for (MCSunnyEpoch *epoch in sunny) [text appendFormat:@"- Clear epoch · %ld days\n", (long)epoch.span];
    [text appendFormat:@"\n## Reading\n\nYour climate is %@. The personal weather library is still %@. Next useful review: %@.\n", climate.climateName, total > 0 && skies.count > 0 ? @"forming a visible pattern" : @"waiting for first signals", skies.count < 7 ? @"record 7 skies for weekly motion" : @"compare this week with the 30-day baseline"];
    return text;
}

- (NSURL *)writeMarkdown:(NSString *)text {
    NSString *name = [NSString stringWithFormat:@"MoodClimate-%ld.md", (long)[NSDate.date timeIntervalSince1970]];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
    [text writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return url;
}

- (NSURL *)writePDF:(NSString *)text {
    NSString *name = [NSString stringWithFormat:@"MoodClimate-%ld.pdf", (long)[NSDate.date timeIntervalSince1970]];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
    CGRect page = CGRectMake(0, 0, 612, 792);
    UIGraphicsBeginPDFContextToFile(url.path, page, nil);
    NSDictionary *title = @{NSFontAttributeName: [UIFont systemFontOfSize:24 weight:UIFontWeightBold], NSForegroundColorAttributeName: UIColor.whiteColor};
    NSDictionary *body = @{NSFontAttributeName: [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.88 alpha:1]};
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    NSInteger index = 0;
    while (index < lines.count) {
        UIGraphicsBeginPDFPageWithInfo(page, nil);
        [[UIColor colorWithRed:0.04 green:0.07 blue:0.12 alpha:1] setFill]; UIRectFill(page);
        [@"Mood Climate" drawAtPoint:CGPointMake(36, 34) withAttributes:title];
        NSMutableString *chunk = [NSMutableString string];
        for (NSInteger row = 0; row < 46 && index < lines.count; row++, index++) [chunk appendFormat:@"%@\n", lines[index]];
        [chunk drawInRect:CGRectMake(36, 82, page.size.width - 72, page.size.height - 118) withAttributes:body];
    }
    UIGraphicsEndPDFContext();
    return url;
}

- (UIImage *)posterWithText:(NSString *)text size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor colorWithRed:0.04 green:0.07 blue:0.12 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    NSDictionary *title = @{NSFontAttributeName: [UIFont systemFontOfSize:28 weight:UIFontWeightBold], NSForegroundColorAttributeName: UIColor.whiteColor};
    NSDictionary *body = @{NSFontAttributeName: [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightRegular], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.86 alpha:1]};
    [@"Mood Climate" drawAtPoint:CGPointMake(28, 30) withAttributes:title];
    [text drawInRect:CGRectMake(28, 88, size.width - 56, size.height - 120) withAttributes:body];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
