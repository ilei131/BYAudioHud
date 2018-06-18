//
//  BYTimerLabel.h
//  BYAudioHud
//
//  Created by Guo Xuelei on 2018/6/17.
//  Copyright © 2018年 Zhanggf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BYTimerLabelType) {
    BYTimerLabelTypeStopWatch,
    BYTimerLabelTypeTimer
};

@class BYTimerLabel;
@protocol BYTimerLabelDelegate <NSObject>

@optional
- (void)timerLabel:(BYTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime;
- (void)timerLabel:(BYTimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(BYTimerLabelType)timerType;
- (NSString*)timerLabel:(BYTimerLabel*)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time;

@end

@interface BYTimerLabel : UILabel

@property (nonatomic, weak) id<BYTimerLabelDelegate> delegate;
@property (nonatomic, copy) NSString *timeFormat;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) NSRange textRange;
@property (nonatomic, strong) NSDictionary *attributedDictionaryForTextInRange;
@property (assign) BYTimerLabelType timerType;

/*Is The Timer Running?*/
@property (assign,readonly) BOOL counting;

/*Do you want to reset the Timer after countdown?*/
@property (assign) BOOL resetTimerAfterFinish;

/*Do you want the timer to count beyond the HH limit from 0-23 e.g. 25:23:12 (HH:mm:ss) */
@property (assign, nonatomic) BOOL shouldCountBeyondHHLimit;
@property (assign, nonatomic) NSTimeInterval offsetTime;

#if NS_BLOCKS_AVAILABLE
@property (copy) void (^endedBlock)(NSTimeInterval);
#endif


/*--------Init methods to choose*/
- (id)initWithTimerType:(BYTimerLabelType)theType;
- (id)initWithLabel:(UILabel*)theLabel andTimerType:(BYTimerLabelType)theType;
- (id)initWithLabel:(UILabel*)theLabel;
/*--------designated Initializer*/
- (id)initWithFrame:(CGRect)frame label:(UILabel*)theLabel andTimerType:(BYTimerLabelType)theType;

/*--------Timer control methods to use*/
- (void)start;
#if NS_BLOCKS_AVAILABLE
- (void)startWithEndingBlock:(void(^)(NSTimeInterval countTime))end; //use it if you are not going to use delegate
#endif
- (void)pause;
- (void)reset;
- (void)stop;

/*--------Setter methods*/
- (void)setCountDownTime:(NSTimeInterval)time;
- (void)setStopWatchTime:(NSTimeInterval)time;
- (void)setCountDownToDate:(NSDate*)date;

- (void)addTimeCountedByTime:(NSTimeInterval)timeToAdd;

/*--------Getter methods*/
- (NSTimeInterval)getTimeCounted;
- (NSTimeInterval)getTimeRemaining;
- (NSTimeInterval)getCountDownTime;
- (void)startWithInterval:(NSTimeInterval)interval;

@end
