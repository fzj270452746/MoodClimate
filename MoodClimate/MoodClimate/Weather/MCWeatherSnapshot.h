#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MCWeatherKind) {
    MCWeatherKindSunny = 0,
    MCWeatherKindCloudy,
    MCWeatherKindOvercast,
    MCWeatherKindDrizzle,
    MCWeatherKindRainstorm,
    MCWeatherKindThunder,
    MCWeatherKindWind,
    MCWeatherKindSnow
};

@interface MCWeatherSnapshot : NSObject
@property (nonatomic) MCWeatherKind kind;
@property (nonatomic) NSInteger force;
@property (nonatomic, strong) NSDate *day;
@property (nonatomic, copy) NSArray<NSString *> *signals;
@property (nonatomic, copy) NSString *memo;
+ (instancetype)sky:(MCWeatherKind)kind force:(NSInteger)force signals:(NSArray<NSString *> *)signals memo:(NSString *)memo day:(NSDate *)day;
+ (instancetype)fromArchive:(NSDictionary *)archive;
- (NSDictionary *)archive;
- (NSString *)title;
- (NSString *)glyph;
- (NSInteger)weight;
@end

NSArray<NSNumber *> *MCWeatherAllKinds(void);
NSString *MCWeatherKindTitle(MCWeatherKind kind);
NSString *MCWeatherKindGlyph(MCWeatherKind kind);

NS_ASSUME_NONNULL_END
