#import "MCClimatePeriod.h"

@implementation MCClimatePeriod
+ (instancetype)periodWithSeason:(NSString *)season climate:(NSString *)climate temperature:(NSInteger)temperature calm:(NSInteger)calm count:(NSInteger)count zone:(NSString *)zone {
    MCClimatePeriod *period = [MCClimatePeriod new];
    period.seasonName = season;
    period.climateName = climate;
    period.temperature = temperature;
    period.calmIndex = calm;
    period.skyCount = count;
    period.mapZone = zone;
    return period;
}
@end
