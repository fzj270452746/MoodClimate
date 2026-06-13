#import "MCSunnyEpoch.h"

@implementation MCSunnyEpoch
+ (instancetype)epochFrom:(NSDate *)start to:(NSDate *)end span:(NSInteger)span {
    MCSunnyEpoch *epoch = [MCSunnyEpoch new];
    epoch.start = start;
    epoch.end = end;
    epoch.span = span;
    return epoch;
}
@end
