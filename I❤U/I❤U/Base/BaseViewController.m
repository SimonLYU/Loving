//
//  BaseViewController.m
//  I❤U
//
//  Created by 吕旭明 on 2018/3/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseHeaders.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.view addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;//双击
    [self.view addGestureRecognizer:doubleTap];
}

#pragma mark - UIGestureRecognizer Action
- (void)pinchAction:(UIPinchGestureRecognizer *)pinch{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoverScaleChangeName object:pinch];
}

- (void)doubleTapped:(UITapGestureRecognizer *)tap{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoverDoubleTapped object:tap];
}
@end
