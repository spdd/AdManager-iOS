//
//  WGTimer.h
//  WordGames
//
//  Created by Dmitry B on 26.02.16.
//
//

#import <Foundation/Foundation.h>

@interface WGTimer : NSObject

@property (nonatomic, copy) NSString *runLoopMode;

+ (WGTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                             target:(id)target
                           selector:(SEL)aSelector
                            repeats:(BOOL)repeats;

- (BOOL)isValid;
- (void)invalidate;
- (BOOL)isScheduled;
- (BOOL)scheduleNow;
- (BOOL)pause;
- (BOOL)resume;
- (NSTimeInterval)initialTimeInterval;

@end
