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
#import "JWDVideoThumbnail.h"
#import "JWDVideoThumbnailView.h"


@interface JWDVideoEditViewController ()<JWDVideoThumbnailViewDelegate>

@property (nonatomic, strong) NSURL               *videlUrl; ///< <#value#>

@property (nonatomic, strong) AVAsset             *asset; ///< <#value#>
@property (nonatomic, strong) AVPlayerItem        *playerItem; ///< <#value#>
@property (nonatomic, strong) AVPlayer            *player; ///< <#value#>
@property (nonatomic, strong) AVPlayerLayer       *playerLayer; ///< <#value#>

@property (nonatomic, strong) NSTimer             *repeatTimer; ///< 循环播放定时器
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, strong) JWDVideoThumbnailView *thumbnailView; ///< <#value#>
@property (nonatomic, assign) CGFloat             startTimeSeconds; ///< <#value#>
@property (nonatomic, assign) CGFloat             endTime; ///< <#value#>

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


    self.thumbnailView = [[JWDVideoThumbnailView alloc] initWithFrame:CGRectMake(0, K_SCREEN_HEIGHT - K_thumbnailView_h - K_thumbnailView_h, K_SCREEN_WIDTH, K_thumbnailView_h)];
    self.thumbnailView.delegate = self;
    [self.view addSubview:self.thumbnailView];

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

    self.asset = [AVAsset assetWithURL:videlUrl];
    // 播放器
    NSArray *keys = @[
                      @"tracks",
                      @"duration",
                      @"commonMetadata",
                      @"availableMediaCharacteristicsWithMediaSelectionOptions"
                      ];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset
                           automaticallyLoadedAssetKeys:keys];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.contentsScale = [UIScreen mainScreen].scale;
    self.playerLayer.frame = CGRectMake(0, 80, self.view.bounds.size.width, K_SCREEN_HEIGHT-260);
    self.playerLayer.backgroundColor = [UIColor yellowColor].CGColor;
    [self.view.layer addSublayer:self.playerLayer];


//    [self addItemEndObserverForPlayerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"status"]) {

        switch (self.playerItem.status) {
            case AVPlayerItemStatusUnknown:

                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                [self.player play];

                [self generateThumbnails];

                [self.thumbnailView videoThumbnailViewStartTimer];
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

    CMTime start = CMTimeMakeWithSeconds(self.startTimeSeconds, self.player.currentTime.timescale);


    __weak typeof(self) weakSelf = self;
    void (^callback)(NSNotification *note) = ^(NSNotification *notification) {
        [weakSelf.player seekToTime:start
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

- (void)generateThumbnails {

    self.imageGenerator =
    [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];

    // Generate the @2x equivalent
    self.imageGenerator.maximumSize = CGSizeMake(200.0f, 0.0f);

    CMTime duration = self.asset.duration;

    NSMutableArray *times = [NSMutableArray array];
    CMTimeValue increment = duration.value / 20;
    CMTimeValue currentValue = 2.0 * duration.timescale;
    while (currentValue <= duration.value) {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }

    __block NSUInteger imageCount = times.count;
    __block NSMutableArray *images = [NSMutableArray array];

    AVAssetImageGeneratorCompletionHandler handler;

    handler = ^(CMTime requestedTime,
                CGImageRef imageRef,
                CMTime actualTime,
                AVAssetImageGeneratorResult result,
                NSError *error) {

        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            id thumbnail =
            [JWDVideoThumbnail thumbnailWithImage:image time:actualTime];
            [images addObject:thumbnail];
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }

        // If the decremented image count is at 0, we're all done.
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"images--%@",images);

//                NSString *name = THThumbnailsGeneratedNotification;
//                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//                [nc postNotificationName:name object:images];

                [self.thumbnailView updateThumbnailView:images];

            });
        }
    };

    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:handler];
}

#pragma mark -
#pragma mark - JWDVideoThumbnailViewDelegate
- (void)videoThumbnailViewStopOrStartPaly:(BOOL)isPlay {
    if (isPlay) {
        [self repeatPlay];
    }else {
        [self.player pause];
    }
}

- (void)videoThumbnailViewMoveDragEditViewStartTimeSeconds:(CGFloat)startTimeSeconds {
    self.startTimeSeconds = startTimeSeconds;
}

- (void)videoThumbnailViewStartEndTime:(CGFloat)endTime {
    self.endTime = endTime;
}

- (void)videoThumbnailViewRepeatPlay {
    [self repeatPlay];
}

#pragma mark  - 编辑区域循环播放
- (void)repeatPlay {

    [self.player play];
    CMTime start = CMTimeMakeWithSeconds(self.startTimeSeconds, self.player.currentTime.timescale);
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
