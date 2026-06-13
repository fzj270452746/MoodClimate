#import "MCStormEvent.h"

@implementation MCStormEvent
+ (instancetype)event:(NSString *)name start:(NSDate *)start end:(NSDate *)end span:(NSInteger)span origin:(NSString *)origin {
    MCStormEvent *storm = [MCStormEvent new];
    storm.name = name;
    storm.start = start;
    storm.end = end;
    storm.span = span;
    storm.origin = origin;
    return storm;
}
@end
