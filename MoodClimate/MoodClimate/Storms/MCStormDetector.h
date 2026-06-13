#import <Foundation/Foundation.h>
#import "MCStormEvent.h"
#import "MCSunnyEpoch.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCStormDetector : NSObject
- (NSArray<MCStormEvent *> *)stormsInSkies:(NSArray<MCWeatherSnapshot *> *)skies;
- (NSArray<MCSunnyEpoch *> *)sunnyEpochsInSkies:(NSArray<MCWeatherSnapshot *> *)skies;
@end

NS_ASSUME_NONNULL_END
