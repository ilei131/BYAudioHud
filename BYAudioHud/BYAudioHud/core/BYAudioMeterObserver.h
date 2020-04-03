//
//  BYAudioMeterObserver.h
//  BYAudioHud
//
//  Created by Guo Xuelei on 2018/6/17.
//  Copyright © 2018年 Zhanggf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class BYAudioMeterObserver;

typedef void (^BYAudioMeterObserverActionBlock)(NSArray *levelMeterStates, BYAudioMeterObserver *meterObserver);
typedef void (^BYAudioMeterObserverErrorBlock)(NSError *error, BYAudioMeterObserver *meterObserver);

/**
 *  错误标识
 */
typedef NS_OPTIONS(NSUInteger, BYAudioMeterObserverErrorCode) {
    BYAudioMeterObserverErrorCodeAboutQueue, //关于音频输入队列的错误
};

@interface LevelMeterState : NSObject

@property (nonatomic, assign) Float32 mAveragePower;
@property (nonatomic, assign) Float32 mPeakPower;

@end

@interface BYAudioMeterObserver : NSObject {
    AudioQueueRef                _audioQueue;
    AudioQueueLevelMeterState    *_levelMeterStates;
}

@property AudioQueueRef audioQueue;

@property (nonatomic, copy) BYAudioMeterObserverActionBlock actionBlock;
@property (nonatomic, copy) BYAudioMeterObserverErrorBlock errorBlock;
@property (nonatomic, assign) NSTimeInterval refreshInterval; //刷新间隔,默认0.1

/**
 *  根据meterStates计算出音量，音量为 0-1
 *
 */
+ (Float32)volumeForLevelMeterStates:(NSArray*)levelMeterStates;

@end
