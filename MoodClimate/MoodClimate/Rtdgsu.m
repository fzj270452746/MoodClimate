//
//  Uocnise.m
//  DreamArchive
//
//  Created by Hades on 2026/6/10.
//

#import "Rtdgsu.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

@interface Rtdgsu ()

@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, copy) void(^callback)(BOOL connected);
@property (nonatomic, assign, readwrite) BOOL connected;

@end

@implementation Rtdgsu
+ (instancetype)shared {
    static Rtdgsu *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[Rtdgsu alloc] init];
    });
    return obj;
}

static void ReachabilityCallback(
    SCNetworkReachabilityRef target,
    SCNetworkReachabilityFlags flags,
    void *info
) {
    Rtdgsu *self = (__bridge Rtdgsu *)info;

    BOOL connected =
        (flags & kSCNetworkReachabilityFlagsReachable) &&
        !(flags & kSCNetworkReachabilityFlagsConnectionRequired);

    dispatch_async(dispatch_get_main_queue(), ^{
        self.connected = connected;

        if (self.callback) {
            self.callback(connected);
        }
    });
}

- (void)start:(void (^)(BOOL))callback {

    self.callback = callback;

    if (self.reachability) {
        return;
    }

    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));

    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;

    self.reachability = SCNetworkReachabilityCreateWithAddress(
        NULL,
        (struct sockaddr *)&address
    );

    SCNetworkReachabilityContext context = {
        0,
        (__bridge void *)self,
        NULL,
        NULL,
        NULL
    };

    SCNetworkReachabilitySetCallback(
        self.reachability,
        ReachabilityCallback,
        &context
    );

    SCNetworkReachabilitySetDispatchQueue(
        self.reachability,
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    );

    [self updateCurrentStatus];
}

- (void)updateCurrentStatus {

    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(
            self.reachability,
            &flags)) {

        BOOL connected =
            (flags & kSCNetworkReachabilityFlagsReachable) &&
            !(flags & kSCNetworkReachabilityFlagsConnectionRequired);

        self.connected = connected;

        if (self.callback) {
            self.callback(connected);
        }
    }
}

- (void)stop {

    if (!self.reachability) {
        return;
    }

    SCNetworkReachabilitySetDispatchQueue(
        self.reachability,
        NULL
    );

    CFRelease(self.reachability);
    self.reachability = NULL;
}

- (void)dealloc {
    [self stop];
}

@end
