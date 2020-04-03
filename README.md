# BYAudioHud
an audio recording hud

![ui](https://github.com/ilei131/BYAudioHud/raw/master/hud.png)

Objective-C用法：

```objective-c
@property (strong, nonatomic) BYAudioHudView *voiceRecordHUD;

- (BYAudioHudView *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[BYAudioHudView alloc] initWithFrame:CGRectMake(0, 0, 196, 208)];
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

- (IBAction)recordAction:(id)sender {
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
}
```

Swift用法：

```swift
lazy var hud: BYAudioHudView = {
    let rect = CGRect(x: 0, y: 0, width: 196, height: 208)
    let hud = BYAudioHudView(frame:rect)
    hud.handler = { [weak self](operation, audioName, audioFullPath) in
        if BYAudioOperationState.stop.rawValue == operation {
            if let path = audioFullPath {
                self?.resultLabel.text = "录制结果\(path)"
            }
        }
    }
    return hud
}()

@IBAction func showHud(_ sender: Any) {
    hud.startRecordingHUD(at: self.view)
}
```

