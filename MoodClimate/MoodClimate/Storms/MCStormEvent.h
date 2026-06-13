#import <Foundation/Foundation.h>
#import "MCWeatherSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCStormEvent : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic) NSInteger span;
@property (nonatomic, copy) NSString *origin;
+ (instancetype)event:(NSString *)name start:(NSDate *)start end:(NSDate *)end span:(NSInteger)span origin:(NSString *)origin;
@end

NS_ASSUME_NONNULL_END
