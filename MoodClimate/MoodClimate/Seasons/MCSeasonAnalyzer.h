#import <Foundation/Foundation.h>
#import "MCWeatherSnapshot.h"
#import "MCClimatePeriod.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCSeasonAnalyzer : NSObject
- (MCClimatePeriod *)readSeasonFromSkies:(NSArray<MCWeatherSnapshot *> *)skies;
@end

NS_ASSUME_NONNULL_END
