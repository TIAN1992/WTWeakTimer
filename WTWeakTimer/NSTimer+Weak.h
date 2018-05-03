//
//  NSTimer+Weak.h
//  TimerDemo
//
//  Created by tianweitao on 2018/5/2.
//  Copyright © 2018年 tianweitao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer(Weak)

- (id)wt_initWithFireDate:(NSDate *)fireDate
                   timeInterval:(NSTimeInterval)timerInterval
                     weakTarget:(id)weakTarget
                       selector:(SEL)selector
                       userInfo:(id)userInfo
                        repeats:(BOOL)repeats;

+ (NSTimer *)wt_timerWithTimeInterval:(NSTimeInterval)timeInterval
                           weakTarget:(id)weakTarget
                             selector:(SEL)selector
                             userInfo:(id)userInfo
                              repeats:(BOOL)repeats;

+ (NSTimer *)wt_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                    weakTarget:(id)weakTarget
                                      selector:(SEL)selector
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)repeats;

@end
