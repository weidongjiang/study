//
//  JWDVideoEditViewController.m
//  JWDVideoPlayEdit
//
//  Created by yixiajwd on 2019/1/11.
//  Copyright © 2019 yixiajwd. All rights reserved.
//

#import "JWDVideoEditViewController.h"

@interface JWDVideoEditViewController ()

@end

@implementation JWDVideoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initAllUI];

    [self setDefautData];

}

- (void)setDefautData {
    self.view.backgroundColor = [UIColor blackColor];



}

- (void)initAllUI {

    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 60, 50)];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(dismissCurrentVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];

}

- (void)dismissCurrentVC {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

@end
