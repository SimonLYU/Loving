//
//  FDAlertView.h
//  TT
//
//  Created by 杨欣 on 15/10/9.
//  Copyright © 2015年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FDAlertViewDelegate;

@interface FDAlertView : UIView

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (weak, nonatomic) id<FDAlertViewDelegate> delegate;

@property (assign, nonatomic) BOOL tapBackgroundDisable;


- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon message:(NSString *)message delegate:(id<FDAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;



// Show the alert view in current window
- (void)show;

- (void)showInBottom;

- (void)showFromTop;

- (void)setIphoneXBottomColorWithColor:(UIColor *)color;

// Hide the alert view
- (void)hide;

- (void)hideWithAnimated:(BOOL)animated;

// Set the color and font size of title, if color is nil, default is black. if fontsize is 0, default is 14
- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size;

// Set the color and font size of message, if color is nil, default is black. if fontsize is 0, default is 12
- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size;

// Set the color and font size of button at the index, if color is nil, default is black. if fontsize is 0, default is 16
- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index;

- (void)setGrayBackgroupColor:(UIColor *)color;

// In some cases we don't want the content show in center
- (void)setContentView:(UIView *)contentView origin:(CGPoint)origin;

@end

@protocol FDAlertViewDelegate <NSObject>

@optional
- (void)alertView:(FDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@optional
- (void)alertViewTapBackground:(FDAlertView *)alertView;


@end
