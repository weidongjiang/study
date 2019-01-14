//
//  JWDDragEditView.m
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/14.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import "JWDDragEditView.h"
#import "JWDVideoDefaultConfign.h"

@interface JWDDragEditView ()

@property (nonatomic, strong) UIImageView        *dragImageView; ///<

@end

@implementation JWDDragEditView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

    // 布局
    self.dragImageView = [[UIImageView alloc] init];
    self.dragImageView.image = [UIImage imageNamed:@"JWDDragImageView"];
    [self addSubview:self.dragImageView];

}

- (void)setIsRight:(BOOL)isRight {
    _isRight = isRight;

    if (isRight) {
        [self.dragImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.width.mas_equalTo(K_JWDDragEditImageView_w);
            make.bottom.equalTo(self);
        }];
    }else {
        [self.dragImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.width.mas_equalTo(K_JWDDragEditImageView_w);
            make.bottom.equalTo(self);
        }];
    }

    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

    return [self pointInsideDragEditView:point];
}

- (BOOL)pointInsideDragEditView:(CGPoint)point {

    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, _hitEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

- (BOOL)pointInsideDragEditViewImgView:(CGPoint)point {

    CGRect relativeFrame = self.dragImageView.frame;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, _hitEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end
