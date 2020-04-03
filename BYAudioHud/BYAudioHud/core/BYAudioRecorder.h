//
//  BYAudioRecorder.h
//  BYAudioHud
//
//  Created by Guo Xuelei on 2018/6/17.
//  Copyright © 2018年 Zhanggf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 *  使用audioqueque来实时录音，边录音边转码，可以设置自己的转码方式。从PCM数据转
 */

//录音停止事件的block回调，作用参考BYAudioRecorderDelegate的recordStopped和recordError:
typedef void (^BYRecorderStoppedBlock)(void);
typedef void (^BYRecorderErrorBlock)(NSError *error);

/**
 *  错误标识
 */
typedef NS_OPTIONS(NSUInteger, BYRecorderErrorCode) {
    BYRecorderErrorCodeAboutFile = 0, //关于文件操作的错误
    BYRecorderErrorCodeAboutQueue, //关于音频输入队列的错误
    BYRecorderErrorCodeAboutSession, //关于audio session的错误
    BYRecorderErrorCodeAboutOther, //关于其他的错误
};

@class BYAudioRecorder;

/**
 *  处理写文件操作的，实际是转码的操作在其中进行。算作可扩展自定义的转码器
 *  当然如果是实时语音的需求的话，就可以在此处理编码后发送语音数据到对方
 *  PS:这里的三个方法是在后台线程中处理的
 */
@protocol FileWriterForAudioRecorder <NSObject>

@optional
- (AudioStreamBasicDescription)customAudioFormatBeforeCreateFile;

@required
/**
 *  在录音开始时候建立文件和写入文件头信息等操作
 *
 */
- (BOOL)createFileWithRecorder:(BYAudioRecorder*)recoder;

/**
 *  写入音频输入数据，内部处理转码等其他逻辑
 *  能传递过来的都传递了。以方便多能扩展使用
 */
- (BOOL)writeIntoFileWithData:(NSData*)data
                 withRecorder:(BYAudioRecorder*)recoder
                         inAQ:(AudioQueueRef)inAQ
                  inStartTime:(const AudioTimeStamp *)inStartTime
                 inNumPackets:(UInt32)inNumPackets
                 inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc;

/**
 *  文件写入完成之后的操作，例如文件句柄关闭等,isError表示是否是因为错误才调用的
 *
 */
- (BOOL)completeWriteWithRecorder:(BYAudioRecorder*)recoder withIsError:(BOOL)isError;

@end

@protocol BYAudioRecorderDelegate <NSObject>

@required
/**
 *  录音遇到了错误，例如创建文件失败啊。写入失败啊。关闭文件失败啊，等等。
 */
- (void)recordError:(NSError *)error;

@optional

/**
 开始录音
 */
- (void)recordStart;

/**
 *  录音被停止
 *  一般是在writer delegate中因为一些状况意外停止录音获得此事件时候使用，参考AmrRecordWriter里实现。
 */
- (void)recordStopped;

@end

@interface BYAudioRecorder : NSObject {
@public
    //音频输入队列
    AudioQueueRef                _audioQueue;
    //音频输入数据format
    AudioStreamBasicDescription    _recordFormat;
}

/**
 *  是否正在录音
 */
@property (assign, nonatomic) BOOL isRecording;

/**
 *  这俩是当前的采样率和缓冲区采集秒数，根据情况可以设置(对其设置必须在startRecording之前才有效)，随意设置可能有意外发生。
 *  这俩属性被标识为原子性的，读取写入是线程安全的。
 */
@property (atomic, assign) Float64 sampleRate;
@property (atomic, assign) double bufferDurationSeconds;

/**
 *  处理写文件操作的，实际是转码的操作在其中进行。算作可扩展自定义的转码器
 */
@property (nonatomic, weak) id<FileWriterForAudioRecorder> fileWriterDelegate;

/**
 *  参考VLAudioRecorderReceiveStoppedBlock和MLAudioRecorderReceiveErrorBlock
 */
@property (nonatomic, copy) BYRecorderStoppedBlock receiveStoppedBlock;
@property (nonatomic, copy) BYRecorderErrorBlock receiveErrorBlock;

/**
 *  参考VLAudioRecorderDelegate
 */
@property (nonatomic, assign) id<BYAudioRecorderDelegate> delegate;

- (void)startRecording;
- (void)stopRecording;
- (void)cancelRecording;


@end
