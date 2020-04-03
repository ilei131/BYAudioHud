//
//  BYAudioHud.h
//  BYAudioHud
//
//  Created by Guo Xuelei on 2018/6/17.
//  Copyright © 2018年 Zhanggf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BYAudioOperationState) {
    BYAudioOperationStateStart = 1,
    BYAudioOperationStateStop = 2,
    BYAudioOperationStateError = 3
};

typedef void (^BYAudioHudHandler)(NSInteger operation, NSString *audioName, NSString *audioFullPath);

@interface BYAudioHudOverlay : UIView

@end

@interface BYAudioHudView : UIView

@property (nonatomic, assign) CGFloat peakPower;
@property (nonatomic, copy) BYAudioHudHandler handler;

/**
 *  开始显示录音HUD控件在某个view
 *
 *  @param view 具体要显示的View
 */
- (void)startRecordingHUDAtView:(UIView *)view;

/**
 *  提示取消录音
 */
- (void)pauseRecord;

/**
 *  提示继续录音
 */
- (void)resaueRecord;

/**
 *  停止录音，意思是完成录音
 *
 *  @param compled 完成录音后的block回调
 */
- (void)stopRecordCompled:(void(^)(BOOL fnished))compled;

/**
 *  取消录音
 *
 *  @param compled 取消录音完成后的回调
 */
- (void)cancelRecordCompled:(void(^)(BOOL fnished))compled;

@end
