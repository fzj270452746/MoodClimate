//
//  Uocnise.h
//  DreamArchive
//
//  Created by Hades on 2026/6/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Rtdgsu : NSObject
+ (instancetype)shared;

/// 开始监听网络状态
- (void)start:(void(^)(BOOL connected))callback;

/// 停止监听
- (void)stop;

/// 当前是否联网
@property (nonatomic, assign, readonly) BOOL connected;
@end

NS_ASSUME_NONNULL_END
