//
//  JWDVideoThumbnailView.m
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/11.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import "JWDVideoThumbnailView.h"
#import "JWDVideoThumbnail.h"
#import "JWDVideoDefaultConfign.h"
#import "JWDDragEditView.h"

@interface JWDVideoThumbnailView ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray                *thumbnails; ///< <#value#>
@property (nonatomic, strong) UIScrollView           *scrollView; ///< <#value#>
@property (nonatomic, strong) JWDDragEditView        *leftDragEditView; ///< value
@property (nonatomic, strong) JWDDragEditView        *rightDragEditView; ///< <#value#>
@property (nonatomic, strong) UIView        *topBorder; ///< <#value#>
@property (nonatomic, strong) UIView        *bottomBorder; ///< <#value#>

@property (nonatomic, assign) BOOL         isDraggingRightOverlayView; ///< <#value#>
@property (nonatomic, assign) BOOL         isDraggingLeftOverlayView; ///< <#value#>
@property (nonatomic, assign) CGFloat         touchPointX; ///< <#value#>
@property (nonatomic, assign) CGPoint         rightStartPoint; ///< <#value#>
@property (nonatomic, assign) CGPoint         leftStartPoint; ///< value

@property (nonatomic, assign) CGFloat         startTime; ///< <#value#>
@property (nonatomic, assign) CGFloat         endTime; ///< <#value#>
@property (nonatomic, assign) CGFloat         startPointX; ///< <#value#>
@property (nonatomic, assign) CGFloat         endPointX; ///< <#value#>
@property (nonatomic, assign) CGFloat         IMG_Width; ///< <#value#>
@property (nonatomic, assign) CGFloat         boderX;    ///< 编辑框边线X
@property (nonatomic, assign) CGFloat         boderWidth; ///< 编辑框边线长度

@property (nonatomic, assign) BOOL            isPanLeftOrRightDraggingView; ///< 是否在移动标签上滑动 yes在


@end

@implementation JWDVideoThumbnailView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        // 默认startTime 0秒 endTime 10秒
        self.startTime = 0;
        self.endTime = 10;
        self.startPointX = 50;
        self.endPointX = K_SCREEN_WIDTH - 50;
        self.IMG_Width = (K_SCREEN_WIDTH - 100)/10;

        [self setupView];
    }
    return self;
}

- (void)setupView {

    // 布局
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_WIDTH, K_thumbnailView_h)];
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];


    // 添加编辑框上下边线
    CGFloat boderX = K_DragEditViewWidth;
    CGFloat boderWidth = K_SCREEN_WIDTH - 2*K_DragEditViewWidth;

    self.boderX = boderX;
    self.boderWidth = boderWidth;

    self.topBorder = [[UIView alloc] initWithFrame:CGRectMake(boderX, 0, boderWidth, 2)];
    self.topBorder.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.topBorder];

    self.bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(boderX, K_thumbnailView_h-2, boderWidth, 2)];
    self.bottomBorder.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomBorder];


    self.leftDragEditView = [[JWDDragEditView alloc] initWithFrame:CGRectMake(-(K_SCREEN_WIDTH-K_DragEditViewWidth), 0, K_SCREEN_WIDTH, K_thumbnailView_h)];
    self.leftDragEditView.isRight = YES;
    self.leftDragEditView.hitEdgeInsets = UIEdgeInsetsMake(0, -(K_EDGE_EXTENSION_FOR_THUMB), 0, -(K_EDGE_EXTENSION_FOR_THUMB));
    [self addSubview:self.leftDragEditView];


    self.rightDragEditView = [[JWDDragEditView alloc] initWithFrame:CGRectMake(K_SCREEN_WIDTH - K_DragEditViewWidth, 0, K_SCREEN_WIDTH, K_thumbnailView_h)];
    self.rightDragEditView.isRight = NO;
    self.rightDragEditView.hitEdgeInsets = UIEdgeInsetsMake(0, -(K_EDGE_EXTENSION_FOR_THUMB), 0, -(K_EDGE_EXTENSION_FOR_THUMB));

    [self addSubview:self.rightDragEditView];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveDragEditView:)];
    [self addGestureRecognizer:pan];

}


- (void)updateThumbnailView:(NSArray *)thumbnails {

    self.thumbnails = thumbnails;

    CGFloat currentX = 0.0f;

    CGSize size = [(UIImage *)[[self.thumbnails firstObject] image] size];

    CGSize imageSize = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(0.5, 0.5));

    imageSize.width = imageSize.width*K_thumbnailView_h/imageSize.height;
    imageSize.height = K_thumbnailView_h;

    CGRect imageRect = CGRectMake(currentX, 0, imageSize.width, imageSize.height);

    CGFloat imageWidth = CGRectGetWidth(imageRect) * self.thumbnails.count;
    self.scrollView.contentSize = CGSizeMake(imageWidth, imageRect.size.height);

    for (NSUInteger i = 0; i < self.thumbnails.count; i++) {
        JWDVideoThumbnail *timedImage = self.thumbnails[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.adjustsImageWhenHighlighted = NO;
        [button setBackgroundImage:timedImage.image forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(imageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(currentX, 0, imageSize.width, imageSize.height);
        button.tag = i;
        [self.scrollView addSubview:button];
        currentX += imageSize.width;
    }
}

- (void)moveDragEditView:(UIPanGestureRecognizer *)gestureRecognizer {


    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {

            BOOL isRight =  [self.rightDragEditView pointInsideDragEditViewImgView:[gestureRecognizer locationInView:self.rightDragEditView]];
            BOOL isLeft  =  [self.leftDragEditView pointInsideDragEditViewImgView:[gestureRecognizer locationInView:self.leftDragEditView]];

            self.isDraggingRightOverlayView = NO;
            self.isDraggingLeftOverlayView = NO;

            self.touchPointX = [gestureRecognizer locationInView:self].x;

            if (isRight){
                self.rightStartPoint = [gestureRecognizer locationInView:self];
                self.isDraggingRightOverlayView = YES;
                self.isDraggingLeftOverlayView = NO;

                if (self.delegate && [self.delegate respondsToSelector:@selector(stopOrStartPaly:)]) {
                    [self.delegate stopOrStartPaly:NO];
                }
            }

            if (isLeft){
                self.leftStartPoint = [gestureRecognizer locationInView:self];
                self.isDraggingRightOverlayView = NO;
                self.isDraggingLeftOverlayView = YES;

                if (self.delegate && [self.delegate respondsToSelector:@selector(stopOrStartPaly:)]) {
                    [self.delegate stopOrStartPaly:NO];
                }
            }

        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gestureRecognizer locationInView:self];

            if (self.isDraggingRightOverlayView) {// 移动右边
                NSLog(@"向右移动");

                self.isPanLeftOrRightDraggingView = NO;

                CGFloat deltaX = point.x - self.rightStartPoint.x;
                CGPoint center = self.rightDragEditView.center;
                center.x += deltaX;
                CGFloat durationTime = (K_SCREEN_WIDTH-100)*2/10; // 最小范围2秒
                BOOL flag = (point.x-self.startPointX) > durationTime;
                if (center.x <= (K_SCREEN_WIDTH-50 + K_SCREEN_WIDTH/2) && flag) {
                    self.rightDragEditView.center = center;
                    self.rightStartPoint = point;
                    self.endTime = (point.x+self.scrollView.contentOffset.x)/self.IMG_Width;
                    self.topBorder.frame = CGRectMake(self.boderX, 0, self.boderWidth+=deltaX/2, 2);
                    self.bottomBorder.frame = CGRectMake(self.boderX, 50-2, self.boderWidth+=deltaX/2, 2);
                    self.endPointX = point.x;

                }

                CGFloat startTimeSeconds = (point.x+self.scrollView.contentOffset.x)/self.IMG_Width;
                if (self.delegate && [self.delegate respondsToSelector:@selector(moveDragEditViewStartTimeSeconds:)]) {
                    [self.delegate moveDragEditViewStartTimeSeconds:startTimeSeconds];
                }

                if (self.delegate && [self.delegate respondsToSelector:@selector(startEndTime:)]) {
                    [self.delegate startEndTime:self.endTime];
                }
            }else if (self.isDraggingLeftOverlayView) {// 移动左边
                NSLog(@"向左移动");
                self.isPanLeftOrRightDraggingView = NO;

                CGFloat deltaX = point.x - self.leftStartPoint.x;
                CGPoint center = self.leftDragEditView.center;
                center.x += deltaX;
                CGFloat durationTime = (K_SCREEN_WIDTH - 100)*2/10; // 最小范围2秒
                BOOL flag = (self.endPointX-point.x) > durationTime;

                if (center.x >= (50 - K_SCREEN_WIDTH/2) && flag) {

                    self.leftDragEditView.center = center;
                    self.leftStartPoint = point;
                    self.startTime = (point.x + self.scrollView.contentOffset.x)/self.IMG_Width;

                    self.topBorder.frame = CGRectMake(self.boderX+=deltaX/2, 0, self.boderWidth-=deltaX/2, 2);
                    self.bottomBorder.frame = CGRectMake(self.boderX+=deltaX/2, 50-2, self.boderWidth-=deltaX/2, 2);
                    self.startPointX = point.x;

                }

                CGFloat startTimeSeconds = (point.x+self.scrollView.contentOffset.x)/self.IMG_Width;

                if (self.delegate && [self.delegate respondsToSelector:@selector(moveDragEditViewStartTimeSeconds:)]) {
                    [self.delegate moveDragEditViewStartTimeSeconds:startTimeSeconds];
                }

                if (self.delegate && [self.delegate respondsToSelector:@selector(startEndTime:)]) {
                    [self.delegate startEndTime:self.endTime];
                }

            }else {
                NSLog(@"scrollView---");
                self.isPanLeftOrRightDraggingView = YES;
            }

        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.isPanLeftOrRightDraggingView) {
                return;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(stopOrStartPaly:)]) {
                [self.delegate stopOrStartPaly:YES];
            }
        }
            break;

        default:
            break;
    }

}

#pragma mark  - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stopOrStartPaly:)]) {
        [self.delegate stopOrStartPaly:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stopOrStartPaly:)]) {
        [self.delegate stopOrStartPaly:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self letScrollViewScrollAndResetPlayerStartTime];
    // 视频暂停时可通过  AVPlayerItem 的API - (void)stepByCount:(NSInteger)stepCount; 滑动，目前未找到step的具体大小 官方文档说的不清楚
    //    NSInteger step = offsetX/(50.0*self.framesArray.count)*72;
    //    NSLog(@"移动步数:%ld",step);
    //    if ([self.playItem canStepForward] && step > 0) {
    //        [self.playItem stepByCount:step];
    //    }
    //
    //    if ([self.playItem canStepBackward] && step < 0) {
    //         [self.playItem stepByCount:step];
    //    }
}
- (void)letScrollViewScrollAndResetPlayerStartTime {

    CGFloat offsetX = self.scrollView.contentOffset.x;
//    CMTime startTime;

    if (offsetX >= 0) {
        CGFloat duration = self.endTime - self.startTime;
        self.startTime = (offsetX+self.startPointX)/self.IMG_Width;
        self.endTime = self.startTime + duration;

//        startTime = CMTimeMakeWithSeconds((offsetX+self.startPointX)/self.IMG_Width, self.player.currentTime.timescale);

        CGFloat startTimeSeconds = (offsetX+self.startPointX)/self.IMG_Width;
        if (self.delegate && [self.delegate respondsToSelector:@selector(moveDragEditViewStartTimeSeconds:)]) {
            [self.delegate moveDragEditViewStartTimeSeconds:startTimeSeconds];
        }

    }else {


        CGFloat startTimeSeconds = self.startPointX;
        if (self.delegate && [self.delegate respondsToSelector:@selector(moveDragEditViewStartTimeSeconds:)]) {
            [self.delegate moveDragEditViewStartTimeSeconds:startTimeSeconds];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(startEndTime:)]) {
        [self.delegate startEndTime:self.endTime];
    }

    // 只有视频播放的时候才能够快进和快退1秒以内
//    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

    if (self.delegate && [self.delegate respondsToSelector:@selector(stopOrStartPaly:)]) {
        [self.delegate stopOrStartPaly:YES];
    }

}

@end
