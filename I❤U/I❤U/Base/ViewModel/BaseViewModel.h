//
//  BaseViewModel.h
//  CMFinancialServices
//
//  Created by 506208 on 2017/6/7.
//  Copyright © 2017年 GiveU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHeaders.h"

@class BaseViewController;

@interface BaseViewModel : NSObject

/**
 对应的VC
 */
@property (nonatomic, weak) __kindof UIViewController *viewController;
/**
 *  vc命名
 */
@property (nonatomic, strong) NSString *vcName;
/**
 *  vc标题
 */
@property (nonatomic, strong) NSString *title;

/**
 分页计算时 当前页面的值
 */
@property (nonatomic, assign) NSUInteger currentPage;
/**
 分页计算时 总页数
 */
@property (nonatomic, assign) NSUInteger totalPages;

/**
 分页加载上拉没有更多数据了
 */
@property (nonatomic, assign) BOOL setNoMoreData;

- (instancetype)initWithVCName:(NSString *)vcName;
- (instancetype)initWithVCName:(NSString *)vcName withInitType:(GULoadVC)loadType;
- (void)initialize;

/**
 返回当前viewmodel对应的vc
 */
- (__kindof UIViewController *)loadedVC;

#pragma mark - push action
- (void)pushViewModel:(BaseViewModel *)viewModel animated:(BOOL)animated;

- (__kindof UIViewController *)popViewModelAnimated:(BOOL)animated;

- (NSArray<__kindof UIViewController *> *)popToViewModel:(BaseViewModel *)viewModel animated:(BOOL)animated;

- (NSArray<__kindof UIViewController *> *)popToRootViewModelAnimated:(BOOL)animated;

#pragma mark - present action

- (void)presentViewModel:(BaseViewModel *)viewModel animated:(BOOL)animated completion:(void (^)(void))completion;

- (void)dismissViewModelAnimated:(BOOL)animated completion: (void (^)(void))completion;

@end
