//
//  JWDVideoThumbnail.m
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/11.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import "JWDVideoThumbnail.h"

@implementation JWDVideoThumbnail

+ (instancetype)thumbnailWithImage:(UIImage *)image time:(CMTime)time {
    return [[self alloc] initWithImage:image time:time];
}

- (id)initWithImage:(UIImage *)image time:(CMTime)time {
    self = [super init];
    if (self) {
        _image = image;
        _time = time;
    }
    return self;
}

@end
