#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCSunnyEpoch : NSObject
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic) NSInteger span;
+ (instancetype)epochFrom:(NSDate *)start to:(NSDate *)end span:(NSInteger)span;
@end

NS_ASSUME_NONNULL_END
