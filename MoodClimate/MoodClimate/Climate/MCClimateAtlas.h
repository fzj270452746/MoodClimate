#import <Foundation/Foundation.h>
#import "MCChronicleVault.h"
#import "MCSeasonAnalyzer.h"
#import "MCStormDetector.h"
#import "MCReportForge.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCClimateAtlas : NSObject
@property (nonatomic, strong, readonly) MCChronicleVault *vault;
@property (nonatomic, strong, readonly) MCSeasonAnalyzer *seasoner;
@property (nonatomic, strong, readonly) MCStormDetector *stormer;
@property (nonatomic, strong, readonly) MCReportForge *forge;
- (instancetype)initWithVault:(MCChronicleVault *)vault;
- (MCClimatePeriod *)currentClimate;
- (NSArray<MCStormEvent *> *)storms;
- (NSArray<MCSunnyEpoch *> *)sunnyEpochs;
@end

NS_ASSUME_NONNULL_END
