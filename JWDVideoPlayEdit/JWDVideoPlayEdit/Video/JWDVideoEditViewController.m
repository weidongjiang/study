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

- (void)dismissCurrentVC {
    NSLog(@"dismissCurrentVC");
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

@end
