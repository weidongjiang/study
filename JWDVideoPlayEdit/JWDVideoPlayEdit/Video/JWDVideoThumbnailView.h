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

- (void)moveDragEditViewStartTimeSeconds:(CGFloat)startTimeSeconds;
- (void)stopOrStartPaly:(BOOL)isPlay;

- (void)startEndTime:(CGFloat)endTime;

@end


@interface JWDVideoThumbnailView : UIView

@property (nonatomic, weak) id<JWDVideoThumbnailViewDelegate>         delegate; ///< <#value#>


- (void)updateThumbnailView:(NSArray *)thumbnails;

@end

NS_ASSUME_NONNULL_END
