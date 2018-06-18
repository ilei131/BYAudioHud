//
//  BYAudioHud.m
//  BYAudioHud
//
//  Created by Guo Xuelei on 2018/6/17.
//  Copyright © 2018年 Zhanggf. All rights reserved.
//

#import "BYAudioHud.h"
#import "BYAudioRecorder.h"
#import "BYMp3Writer.h"
#import "BYAudioMeterObserver.h"

@implementation BYAudioHudOverlay

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:tap];
    }
    return self;
}

@end

@interface BYAudioHud() <BYAudioRecorderDelegate>

@property (nonatomic, weak) UILabel *remindLabel;
@property (nonatomic, strong) UIImageView *microPhoneImageView;
@property (nonatomic, strong) UIImageView *recordingHUDImageView;
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) BYAudioHudOverlay *overlayView;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) BYAudioRecorder *recorder;
@property (nonatomic, strong) BYMp3Writer *mp3Writer;
@property (nonatomic, strong) BYAudioMeterObserver *meterObserver;
@property (nonatomic, copy) NSString *audioName;
@property (nonatomic, copy) NSString *audioFullPath;

/**
 *  逐渐消失自身
 *
 *  @param compled 消失完成的回调block
 */
- (void)dismissCompled:(void(^)(BOOL fnished))compled;

/**
 *  配置是否正在录音，需要隐藏和显示某些特殊的控件
 *
 *  @param recording 是否录音中
 */
- (void)configRecoding:(BOOL)recording;

/**
 *  根据语音输入的大小来配置需要显示的HUD图片
 *
 *  @param peakPower 输入音频的声音大小
 */
- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower;

/**
 *  配置默认参数
 */
- (void)setup;

@end

@implementation BYAudioHud

- (BYAudioRecorder *)recorder {
    if (!_recorder) {
        _recorder = [[BYAudioRecorder alloc] init];
        __weak __typeof(self)weakSelf = self;
        _recorder.receiveStoppedBlock = ^{
            weakSelf.meterObserver.audioQueue = nil;
        };
        _recorder.receiveErrorBlock = ^(NSError *error){
            weakSelf.meterObserver.audioQueue = nil;
        };
        _recorder.delegate = self;
    }
    return _recorder;
}

- (BYMp3Writer *)mp3Writer {
    if (!_mp3Writer) {
        _mp3Writer = [[BYMp3Writer alloc]init];
        _mp3Writer.maxSecondCount = 180;
        _mp3Writer.maxFileSize = 1024*1024*3;
    }
    return _mp3Writer;
}

- (BYAudioMeterObserver *)meterObserver {
    if (!_meterObserver) {
        _meterObserver = [[BYAudioMeterObserver alloc] init];
        __weak typeof(self) weakSelf = self;
        _meterObserver.actionBlock = ^(NSArray *levelMeterStates, BYAudioMeterObserver *meterObserver){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.peakPower = [BYAudioMeterObserver volumeForLevelMeterStates:levelMeterStates];
        };
        _meterObserver.errorBlock = ^(NSError *error, BYAudioMeterObserver *meterObserver){
            
        };
    }
    return _meterObserver;
}


- (void)pauseRecord {
    
}

- (void)startRecordingHUDAtView:(UIView *)view {
    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
    self.center = center;
    
    BYAudioHudOverlay *overlayView = [[BYAudioHudOverlay alloc] initWithFrame:view.bounds];
    self.overlayView = overlayView;
    
    [self.overlayView addSubview:self];
    [view addSubview:self.overlayView];
}

- (void)resaueRecord {
    [self configRecoding:NO];
}

- (void)stopRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)cancelRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)dismissCompled:(void(^)(BOOL fnished))compled {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.overlayView removeFromSuperview];
        self.alpha = 1;
        if (compled) {
            compled(finished);
        }
    }];
}

- (void)configRecoding:(BOOL)recording {
    //    self.microPhoneImageView.hidden = !recording;
    //    self.recordingHUDImageView.hidden = !recording;
    //    self.cancelRecordImageView.hidden = recording;
}

- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower {
    NSString *imageName = @"RecordingSignal00";
    if (peakPower >= 0 && peakPower <= 0.1) {
        imageName = [imageName stringByAppendingString:@"1"];
    } else if (peakPower > 0.1 && peakPower <= 0.2) {
        imageName = [imageName stringByAppendingString:@"2"];
    } else if (peakPower > 0.3 && peakPower <= 0.4) {
        imageName = [imageName stringByAppendingString:@"3"];
    } else if (peakPower > 0.4 && peakPower <= 0.5) {
        imageName = [imageName stringByAppendingString:@"4"];
    } else if (peakPower > 0.5 && peakPower <= 0.6) {
        imageName = [imageName stringByAppendingString:@"5"];
    } else if (peakPower > 0.7 && peakPower <= 0.8) {
        imageName = [imageName stringByAppendingString:@"6"];
    } else if (peakPower > 0.8 && peakPower <= 0.9) {
        imageName = [imageName stringByAppendingString:@"7"];
    } else if (peakPower > 0.9 && peakPower <= 1.0) {
        imageName = [imageName stringByAppendingString:@"8"];
    }
    self.recordingHUDImageView.image = [UIImage imageNamed:imageName];
}

- (void)setPeakPower:(CGFloat)peakPower {
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

- (void)setup {
    //self.backgroundColor = [UIColor colorWithRed:0.200f green:0.200f blue:0.200f alpha:0.4f];
    self.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.6f];
    //self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    
    if (!_microPhoneImageView) {
        UIImageView *microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(55.0, 8.0, 50.0, 99.0)];
        microPhoneImageView.image = [UIImage imageNamed:@"RecordingBkg"];
        microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        microPhoneImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:microPhoneImageView];
        _microPhoneImageView = microPhoneImageView;
    }
    
    if (!_recordingHUDImageView) {
        UIImageView *recordHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110.0, 34.0, 18.0, 61.0)];
        recordHUDImageView.image = [UIImage imageNamed:@"RecordingSignal001"];
        recordHUDImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        recordHUDImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:recordHUDImageView];
        _recordingHUDImageView = recordHUDImageView;
    }
    
    self.timeLabel.frame = CGRectMake(0, 102.0, self.frame.size.width, 21);
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timeLabel];
    
    self.startBtn.frame = CGRectMake(10, 130, self.frame.size.width-20, 30);
    self.startBtn.layer.cornerRadius = 15;
    [self addSubview:self.startBtn];
    
    self.cancelBtn.frame = CGRectMake(10, 168, self.frame.size.width-20, 30);
    self.cancelBtn.layer.cornerRadius = 15;
    [self addSubview:self.cancelBtn];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (BYTimerLabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[BYTimerLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.timeLabel.font = [UIFont systemFontOfSize:14.0f];
        _timeLabel.timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setTitle:@"开始录音" forState:UIControlStateNormal];
        [_startBtn setTitle:@"开始录音" forState:UIControlStateHighlighted];
        [_startBtn setBackgroundColor:[UIColor colorWithRed:1.000f green:0.455f blue:0.365f alpha:1.00f]];
        [_startBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateHighlighted];
        [_cancelBtn setBackgroundColor:[UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:1.00]];
        [_cancelBtn addTarget:self action:@selector(cancelRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (void)startRecord {
    if (_isRecording) {
        _isRecording = NO;
        [self.timeLabel stop];
        [self.recorder stopRecording];
        [self dismissCompled:nil];
        [_startBtn setTitle:@"开始录音" forState:UIControlStateNormal];
        [_startBtn setTitle:@"开始录音" forState:UIControlStateHighlighted];
    }else {
        _isRecording = YES;
        [self.timeLabel start];
        [self recordStartRecording];
        [_startBtn setTitle:@"停止录音" forState:UIControlStateNormal];
        [_startBtn setTitle:@"停止录音" forState:UIControlStateHighlighted];
    }
}

- (NSString *)currentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *timeDir = [NSString stringWithFormat:@"%@", str];
    return timeDir;
}

- (void)recordStartRecording {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *audioName = [self currentTime];
    _audioName = [NSString stringWithFormat:@"%@.mp3" ,audioName];
    _audioFullPath = [path stringByAppendingPathComponent:_audioName];
    self.mp3Writer.filePath = _audioFullPath;
    self.recorder.fileWriterDelegate = self.mp3Writer;
    self.recorder.bufferDurationSeconds = 0.25;
    [self.recorder startRecording];
    self.meterObserver.audioQueue = self.recorder->_audioQueue;
}

- (void)cancelRecord {
    _isRecording = NO;
    [self.timeLabel stop];
    [self dismissCompled:nil];
    [_startBtn setTitle:@"开始录音" forState:UIControlStateNormal];
    [_startBtn setTitle:@"开始录音" forState:UIControlStateHighlighted];
}

- (void)recordError:(NSError *)error {
    if (self.handler) {
        //取消录音
        self.handler(BYAudioOperationStateError, [_audioName copy], [_audioFullPath copy]);
    }
}

- (void)recordStart {
    if (self.handler) {
        //开始录音
        self.handler(BYAudioOperationStateStart, [_audioName copy], [_audioFullPath copy]);
    }
}

- (void)recordStopped {
    if (self.handler) {
        //录音结束
        self.handler(BYAudioOperationStateStop, [_audioName copy], [_audioFullPath copy]);
    }
}

@end
