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

@property (nonatomic, strong) NSTimer         *repeatTimer; ///< <#value#>
@property (nonatomic, strong) NSTimer         *lineMoveTimer; ///<
@property (nonatomic, strong) UIView          *movelLineView; ///< <#value#>
@property (nonatomic, assign) CGFloat         linePositionX; ///< <#value#>


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


    self.movelLineView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 3, K_thumbnailView_h)];
    self.movelLineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.movelLineView];

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

                if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewStopOrStartPaly:)]) {
                    [self.delegate videoThumbnailViewStopOrStartPaly:NO];
                }

                [self repeatTimerInvalidate];
            }

            if (isLeft){
                self.leftStartPoint = [gestureRecognizer locationInView:self];
                self.isDraggingRightOverlayView = NO;
                self.isDraggingLeftOverlayView = YES;

                if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewStopOrStartPaly:)]) {
                    [self.delegate videoThumbnailViewStopOrStartPaly:NO];
                }
                [self repeatTimerInvalidate];
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
                if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewMoveDragEditViewStartTimeSeconds:)]) {
                    [self.delegate videoThumbnailViewMoveDragEditViewStartTimeSeconds:startTimeSeconds];
                }

                if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewStartEndTime:)]) {
                    [self.delegate videoThumbnailViewStartEndTime:self.endTime];
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

                if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewMoveDragEditViewStartTimeSeconds:)]) {
                    [self.delegate videoThumbnailViewMoveDragEditViewStartTimeSeconds:startTimeSeconds];
                }

                if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewStartEndTime:)]) {
                    [self.delegate videoThumbnailViewStartEndTime:self.endTime];
                }

            }else {
                NSLog(@"scrollView---");
                self.isPanLeftOrRightDraggingView = YES;

                CGFloat deltaX = point.x - self.touchPointX;
                CGFloat newOffset = self.scrollView.contentOffset.x-deltaX;
                CGPoint currentOffSet = CGPointMake(newOffset, 0);

                if (currentOffSet.x >= 0 && currentOffSet.x <= (self.scrollView.contentSize.width-K_SCREEN_WIDTH)) {
                    self.scrollView.contentOffset = CGPointMake(newOffset, 0);
                    self.touchPointX = point.x;
                }

            }

        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.isPanLeftOrRightDraggingView) {
                return;
            }
            [self videoThumbnailViewStartTimer];
        }
            break;

        default:
            break;
    }

}

#pragma mark  - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewStopOrStartPaly:)]) {
        [self.delegate videoThumbnailViewStopOrStartPaly:NO];
    }
    [self repeatTimerInvalidate];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    [self videoThumbnailViewStartTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [self letScrollViewScrollAndResetPlayerStartTime];

}

- (void)letScrollViewScrollAndResetPlayerStartTime {

    CGFloat offsetX = self.scrollView.contentOffset.x;

    if (offsetX >= 0) {

        CGFloat duration = self.endTime - self.startTime;
        self.startTime = (offsetX+self.startPointX)/self.IMG_Width;
        self.endTime = self.startTime + duration;

        CGFloat startTimeSeconds = (offsetX+self.startPointX)/self.IMG_Width;
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewMoveDragEditViewStartTimeSeconds:)]) {
            [self.delegate videoThumbnailViewMoveDragEditViewStartTimeSeconds:startTimeSeconds];
        }

    }else {


        CGFloat startTimeSeconds = self.startPointX;
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewMoveDragEditViewStartTimeSeconds:)]) {
            [self.delegate videoThumbnailViewMoveDragEditViewStartTimeSeconds:startTimeSeconds];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewStartEndTime:)]) {
        [self.delegate videoThumbnailViewStartEndTime:self.endTime];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewStopOrStartPaly:)]) {
        [self.delegate videoThumbnailViewStopOrStartPaly:YES];
    }

}

- (void)videoThumbnailViewStartTimer {

    [self repeatTimerInvalidate];
    [self lineMoveTimerInvalidate];

    double duarationTime = (self.endPointX-self.startPointX-20)/K_SCREEN_WIDTH*10;

    self.movelLineView.hidden = NO;
    self.linePositionX = self.startPointX+10;
    self.lineMoveTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(lineMove) userInfo:nil repeats:YES];

    // 开启循环播放
    self.repeatTimer = [NSTimer scheduledTimerWithTimeInterval:duarationTime target:self selector:@selector(repeatPlay) userInfo:nil repeats:YES];
    [self.repeatTimer fire];
}

- (void)repeatPlay {
    NSLog(@"repeatPlay----循环");
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoThumbnailViewRepeatPlay)]) {
        [self.delegate videoThumbnailViewRepeatPlay];
    }
}

- (void)lineMove {

    self.movelLineView.hidden = NO;

    double duarationTime = (self.endPointX-self.startPointX-20)/K_SCREEN_WIDTH*10;
    self.linePositionX += 0.01*(self.endPointX - self.startPointX-20)/duarationTime;

    if (self.linePositionX >= CGRectGetMinX(self.rightDragEditView.frame)-3) {
        self.linePositionX = CGRectGetMaxX(self.leftDragEditView.frame)+3;
    }

    self.movelLineView.frame = CGRectMake(self.linePositionX, 0, 3, 50);
}

- (void)repeatTimerInvalidate {
    if (self.repeatTimer) {
        [self.repeatTimer invalidate];
        self.repeatTimer = nil;
    }
}

- (void)lineMoveTimerInvalidate {
    if (self.lineMoveTimer) {
        [self.lineMoveTimer invalidate];
        self.lineMoveTimer = nil;
    }
}

- (void)clean {
    [self repeatTimerInvalidate];
    [self lineMoveTimerInvalidate];
}

@end
