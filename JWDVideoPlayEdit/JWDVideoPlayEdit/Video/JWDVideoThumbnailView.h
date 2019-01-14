//
//  JWDVideoThumbnailView.h
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/11.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JWDVideoThumbnailViewDelegate <NSObject>

- (void)videoThumbnailViewMoveDragEditViewStartTimeSeconds:(CGFloat)startTimeSeconds;
- (void)videoThumbnailViewStopOrStartPaly:(BOOL)isPlay;

- (void)videoThumbnailViewStartEndTime:(CGFloat)endTime;
- (void)videoThumbnailViewRepeatPlay;

@end


@interface JWDVideoThumbnailView : UIView

@property (nonatomic, weak) id<JWDVideoThumbnailViewDelegate>         delegate; ///< <#value#>


- (void)updateThumbnailView:(NSArray *)thumbnails;

- (void)videoThumbnailViewStartTimer;

- (void)videoThumbnailViewRepeatTimerInvalidate;

@end

NS_ASSUME_NONNULL_END
