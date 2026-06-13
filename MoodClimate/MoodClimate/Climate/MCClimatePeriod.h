#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCClimatePeriod : NSObject
@property (nonatomic, copy) NSString *seasonName;
@property (nonatomic, copy) NSString *climateName;
@property (nonatomic) NSInteger temperature;
@property (nonatomic) NSInteger calmIndex;
@property (nonatomic) NSInteger skyCount;
@property (nonatomic, copy) NSString *mapZone;
+ (instancetype)periodWithSeason:(NSString *)season climate:(NSString *)climate temperature:(NSInteger)temperature calm:(NSInteger)calm count:(NSInteger)count zone:(NSString *)zone;
@end

NS_ASSUME_NONNULL_END
