//
//  ViewController.m
//  BYAudioHud
//
//  Created by Guo Xuelei on 2018/6/17.
//  Copyright © 2018年 Zhanggf. All rights reserved.
//

#import "ViewController.h"
#import "BYAudioHud.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (strong, nonatomic) BYAudioHud *voiceRecordHUD;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BYAudioHud *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[BYAudioHud alloc] initWithFrame:CGRectMake(0, 0, 196, 208)];
        __weak typeof(self) weakSelf = self;
        _voiceRecordHUD.handler = ^(NSInteger operation, NSString *audioName, NSString *audioFullPath) {
            if (BYAudioOperationStateStop == operation) {
                if (audioName) {
                    weakSelf.resultLabel.text = [NSString stringWithFormat:@"录制结果%@", audioFullPath];
                }
            }
        };
    }
    return _voiceRecordHUD;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordAction:(id)sender {
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
}

@end
