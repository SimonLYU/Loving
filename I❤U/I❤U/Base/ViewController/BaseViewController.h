//
//  BaseViewController.h
//  I❤U
//
//  Created by 吕旭明 on 2018/3/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BaseViewModel;

@interface BaseViewController : UIViewController

@property (nonatomic, strong, readonly) __kindof BaseViewModel *viewModel;

/**
 * 注册RAC
 * 子类重写时要加super
 */
- (void)registerRacsignal;

/**
 * 绑定一个viewModel
 */
- (void)bandingViewModel:(id)viewModel;

@end
