//
//  JWDDragEditView.h
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/14.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWDDragEditView : UIView

@property (nonatomic, assign) BOOL                 isRight; ///< 布局上是否在右边 yes在右边 no在左边
@property (nonatomic, assign) UIEdgeInsets         hitEdgeInsets; ///< <#value#>


- (BOOL)pointInsideDragEditView:(CGPoint)point;

- (BOOL)pointInsideDragEditViewImgView:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
