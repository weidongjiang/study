//
//  JWDVideoEditViewController.m
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/11.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import "JWDVideoEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "JWDVideoDefaultConfign.h"

@interface JWDVideoEditViewController ()

@property (nonatomic, strong) NSURL               *videlUrl; ///< <#value#>

@property (nonatomic, strong) AVPlayerItem        *playerItem; ///< <#value#>
@property (nonatomic, strong) AVPlayer            *player; ///< <#value#>
@property (nonatomic, strong) AVPlayerLayer       *playerLayer; ///< <#value#>

@property (nonatomic, strong) NSTimer             *repeatTimer; ///< 循环播放定时器

@end

@implementation JWDVideoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    NSLog(@"JWDVideoEditViewController - dealloc");

}

- (instancetype)initWithVideoUrl:(NSURL *)videlUrl {
    if (self = [super init]) {
        self.videlUrl = videlUrl;
        [self initAll];
    }
    return self;
}

- (void)initAll {

    [self initUI];

    [self setDefaultData];

    [self initPlayerWithVideoUrl:self.videlUrl];
}

- (void)setDefaultData {

    self.view.backgroundColor = [UIColor blackColor];

}

- (void)initUI {

    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 60, 50)];
    [cancelBtn setBackgroundColor:[UIColor redColor]];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(dismissCurrentVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];

}


#pragma mark -
#pragma mark - 播放
- (void)initPlayerWithVideoUrl:(NSURL *)videlUrl {

    if (!videlUrl) {
        return;
    }

    // 设置播放声音模式  在静音的时候也可以播放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    // 播放器
    self.playerItem = [[AVPlayerItem alloc] initWithURL:videlUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.contentsScale = [UIScreen mainScreen].scale;
    self.playerLayer.frame = CGRectMake(0, 80, self.view.bounds.size.width, K_SCREEN_HEIGHT-260);
    self.playerLayer.backgroundColor = [UIColor yellowColor].CGColor;
    [self.view.layer addSublayer:self.playerLayer];


    [self addItemEndObserverForPlayerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"status"]) {

        switch (self.playerItem.status) {
            case AVPlayerItemStatusUnknown:

                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                [self.player play];
            }

                break;
            case AVPlayerItemStatusFailed:

                break;

            default:
                break;
        }
    }

    if ([keyPath isEqualToString:@"timeControlStatus"]) {

    }

}

- (void)addItemEndObserverForPlayerItem {


    __weak typeof(self) weakSelf = self;
    void (^callback)(NSNotification *note) = ^(NSNotification *notification) {
        [weakSelf.player seekToTime:kCMTimeZero
                  completionHandler:^(BOOL finished) {
                      NSLog(@"播放完成");
                      [weakSelf repeatPlay];
                  }];
    };

    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:callback];

}


#pragma mark  - 编辑区域循环播放
- (void)repeatPlay {

    [self.player play];
    CMTime start = CMTimeMakeWithSeconds(0, self.player.currentTime.timescale);
    [self.player seekToTime:start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)dismissCurrentVC {
    NSLog(@"dismissCurrentVC");
    [self cleanAll];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void)cleanAll {

    [[NSNotificationCenter defaultCenter] removeObserver:self.playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.player) {
        [self.player pause];
        [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
        self.player = nil;
    }

    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        self.playerItem = nil;
    }

    if (self.playerLayer) {
        self.playerLayer = nil;
    }

    if (self.repeatTimer) {
        [self.repeatTimer invalidate];
        self.repeatTimer = nil;
    }

}

@end
