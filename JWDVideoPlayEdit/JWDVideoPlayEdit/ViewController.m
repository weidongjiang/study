//
//  ViewController.m
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2018/12/24.
//  Copyright © 2018 yixiajwd. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 120, 50)];
    [button setTitle:@"选取编辑视频" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:button];
    self.view.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(selectVideoAsset) forControlEvents:UIControlEventTouchUpInside];

}

- (void)selectVideoAsset{

    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    myImagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    myImagePickerController.delegate = self;
    myImagePickerController.editing = NO;
    [self presentViewController:myImagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [picker dismissViewControllerAnimated:YES completion:nil];

    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
//    VideoEditVC *videoEditVC = [[VideoEditVC alloc] init];
//    videoEditVC.videoUrl = url;
//
//    [self presentViewController:videoEditVC animated:YES completion:^{   }];
    
}


@end
