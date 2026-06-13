#import <UIKit/UIKit.h>
#import "MCWeatherSnapshot.h"
#import "MCStormEvent.h"
#import "MCSunnyEpoch.h"
#import "MCClimatePeriod.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCReportForge : NSObject
- (NSString *)markdownForSkies:(NSArray<MCWeatherSnapshot *> *)skies climate:(MCClimatePeriod *)climate storms:(NSArray<MCStormEvent *> *)storms sunny:(NSArray<MCSunnyEpoch *> *)sunny;
- (NSURL *)writeMarkdown:(NSString *)text;
- (NSURL *)writePDF:(NSString *)text;
- (UIImage *)posterWithText:(NSString *)text size:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
