//
//  UIUtil+TT.h
//  TT
//
//  Created by daixiang on 15/2/13.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIUtil : NSObject 

// 文字提示
+ (void)showHint:(NSString *)text;

// 在指定的view文字显示
+ (void)showHint:(NSString *)text inView:(UIView *)view;

// 不带文字菊花
+ (void)showLoading;

// 带文字菊花
+ (void)showLoadingWithText:(NSString *)text;

// 指定显示在某个view里，用于不希望遮挡用户navigationbar之类的情况
// 比如在controller里传入self.view，这样出菊花的时候用户还是可以后退
+ (void)showLoadingWithText:(NSString *)text inView:(UIView *)view;

// 消除菊花
+ (void)dismissLoading;

+ (void)showError:(NSError *)error;

+ (void)showError:(NSError *)error withMessage:(NSString *)message;

+ (void)showErrorMessage:(NSString *)message; //只显示错误信息，不显示错误代码

+ (CGSize)calculateTextViewSizeForString:(NSString *)string withFont:(UIFont *)font inSize:(CGSize)size;

+ (CGSize)calculateTextViewSizeForAttributedString:(NSAttributedString *)string inSize:(CGSize)size;

+ (NSString *)getLocalErrMessage:(NSError *)error;

@end
