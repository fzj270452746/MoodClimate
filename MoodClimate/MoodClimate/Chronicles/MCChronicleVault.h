#import <Foundation/Foundation.h>
#import "MCWeatherSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCChronicleVault : NSObject
- (NSArray<MCWeatherSnapshot *> *)skies;
- (NSArray<NSDictionary *> *)lifeMarks;
- (NSArray<NSDictionary *> *)reviews;
- (void)placeSky:(MCWeatherSnapshot *)sky;
- (void)removeSkyOnDay:(NSDate *)day;
- (void)placeLifeMark:(NSString *)title detail:(NSString *)detail day:(NSDate *)day;
- (void)placeReview:(NSString *)title body:(NSString *)body day:(NSDate *)day;
- (void)clearAll;
@end

NS_ASSUME_NONNULL_END
