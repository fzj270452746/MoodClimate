#import "MCClimateAtlas.h"

@implementation MCClimateAtlas
- (instancetype)initWithVault:(MCChronicleVault *)vault {
    self = [super init];
    if (self) {
        _vault = vault;
        _seasoner = [MCSeasonAnalyzer new];
        _stormer = [MCStormDetector new];
        _forge = [MCReportForge new];
    }
    return self;
}
- (MCClimatePeriod *)currentClimate { return [self.seasoner readSeasonFromSkies:self.vault.skies]; }
- (NSArray<MCStormEvent *> *)storms { return [self.stormer stormsInSkies:self.vault.skies]; }
- (NSArray<MCSunnyEpoch *> *)sunnyEpochs { return [self.stormer sunnyEpochsInSkies:self.vault.skies]; }
@end
