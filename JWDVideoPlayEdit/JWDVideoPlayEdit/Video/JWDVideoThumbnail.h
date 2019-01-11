//
//  JWDVideoThumbnail.h
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/11.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWDVideoThumbnail : NSObject

+ (instancetype)thumbnailWithImage:(UIImage *)image time:(CMTime)time;

@property (nonatomic, readonly) CMTime time;
@property (strong, nonatomic, readonly) UIImage *image;

@end

NS_ASSUME_NONNULL_END
