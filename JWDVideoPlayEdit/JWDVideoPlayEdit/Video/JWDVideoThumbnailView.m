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

@interface JWDVideoThumbnailView ()

@property (nonatomic, strong) NSArray             *thumbnails; ///< <#value#>
@property (nonatomic, strong) UIScrollView        *scrollView; ///< <#value#>

@end

@implementation JWDVideoThumbnailView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {

    // 布局
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_WIDTH, K_thumbnailView_h)];
    [self addSubview:self.scrollView];


    // 约束
    [self setAllLayoutView];
}

- (void)setAllLayoutView {

    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)updateThumbnailView:(NSArray *)thumbnails {

    self.thumbnails = thumbnails;

    CGFloat currentX = 0.0f;

    CGSize size = [(UIImage *)[[self.thumbnails firstObject] image] size];
    // Scale retina image down to appropriate size
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



@end
