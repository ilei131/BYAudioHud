//
//  BYMp3Writer.h
//  BYAudioHud
//
//  Created by Guo Xuelei on 2018/6/17.
//  Copyright © 2018年 Zhanggf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYAudioRecorder.h"

@interface BYMp3Writer : NSObject <FileWriterForAudioRecorder>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long maxFileSize;
@property (nonatomic, assign) double maxSecondCount;
@property (nonatomic, assign) double recordedSecondCount;

@end
