//
//  NSTimer+Weak.m
//  TimerDemo
//
//  Created by tianweitao on 2018/5/2.
//  Copyright © 2018年 tianweitao. All rights reserved.
//

#import "NSTimer+Weak.h"
#import <objc/runtime.h>

@interface WTWeakTimerProxy : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation WTWeakTimerProxy

- (instancetype)initWithTarget:(id)target selector:(SEL)selector {
    self = [super init];
    if (self) {
        _target = target;
        _selector = selector;
    }
    return self;
}

- (void)timerFired:(NSTimer *)timer {
    if ([self.target respondsToSelector:self.selector]) {
        NSMethodSignature *signature = [self.target methodSignatureForSelector:self.selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        if (signature.numberOfArguments > 2) {
            [invocation setArgument:&timer atIndex:2];
        }
        invocation.selector = self.selector;
        [invocation invokeWithTarget:self.target];
    } else {
        [self.target doesNotRecognizeSelector:self.selector];
    }
}

@end

@interface WTWeakTimerLifeTracker : NSObject

@property (nonatomic, weak) WTWeakTimerProxy *timerProxy;

@end

@implementation WTWeakTimerLifeTracker

- (instancetype)initWithTimerProxy:(WTWeakTimerProxy *)timerProxy {
    self = [super init];
    if (self) {
        _timerProxy = timerProxy;
    }
    return self;
}

- (void)dealloc {
    [self.timerProxy.timer invalidate];
    self.timerProxy.timer = nil;
}

@end


@implementation NSTimer(Weak)

- (id)wt_initWithFireDate:(NSDate *)fireDate
             timeInterval:(NSTimeInterval)timerInterval
               weakTarget:(id)weakTarget
                 selector:(SEL)selector
                 userInfo:(id)userInfo
                  repeats:(BOOL)repeats {
    WTWeakTimerProxy *proxyTarget = [[WTWeakTimerProxy alloc] initWithTarget:weakTarget selector:selector];
    NSTimer *timer = [self initWithFireDate:fireDate interval:timerInterval target:proxyTarget selector:@selector(timerFired:) userInfo:userInfo repeats:repeats];
    proxyTarget.timer = timer;
    WTWeakTimerLifeTracker *lifeTracker = [[WTWeakTimerLifeTracker alloc] initWithTimerProxy:proxyTarget];
    objc_setAssociatedObject(weakTarget, (__bridge void *)lifeTracker, lifeTracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return timer;
}

+ (NSTimer *)wt_timerWithTimeInterval:(NSTimeInterval)timeInterval
                           weakTarget:(id)weakTarget
                             selector:(SEL)selector
                             userInfo:(id)userInfo
                              repeats:(BOOL)repeats {
    WTWeakTimerProxy *proxyTarget = [[WTWeakTimerProxy alloc] initWithTarget:weakTarget selector:selector];
    NSTimer *timer = [self timerWithTimeInterval:timeInterval target:proxyTarget selector:@selector(timerFired:) userInfo:userInfo repeats:repeats];
    proxyTarget.timer = timer;
    WTWeakTimerLifeTracker *lifeTracker = [[WTWeakTimerLifeTracker alloc] initWithTimerProxy:proxyTarget];
    objc_setAssociatedObject(weakTarget, (__bridge void *)lifeTracker, lifeTracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return timer;
}

+ (NSTimer *)wt_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval weakTarget:(id)weakTarget selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats {
    WTWeakTimerProxy *proxyTarget = [[WTWeakTimerProxy alloc] initWithTarget:weakTarget selector:selector];
    NSTimer *timer = [self scheduledTimerWithTimeInterval:timeInterval target:proxyTarget selector:@selector(timerFired:) userInfo:userInfo repeats:repeats];
    proxyTarget.timer = timer;
    WTWeakTimerLifeTracker *lifeTracker = [[WTWeakTimerLifeTracker alloc] initWithTimerProxy:proxyTarget];
    objc_setAssociatedObject(weakTarget,(__bridge void *)lifeTracker, lifeTracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return timer;
}
@end
