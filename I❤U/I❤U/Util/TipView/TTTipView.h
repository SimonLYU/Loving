//
//  TTTipView.h
//  TTFoundation
//
//  Created by daixiang on 15/8/1.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    TTTipViewTypeTextHint,
    TTTipViewTypeLoading,
    TTTipViewTypeImageHint,
} TTTipViewType;

typedef enum
{
    TTTipViewAnimationOptionNoFade             = 0 << 0,    //default
    TTTipViewAnimationOptionFadeIn             = 1 << 0,
    TTTipViewAnimationOptionFadeOut            = 2 << 0,
    TTTipViewAnimationOptionFadeInOut          = 3 << 0,
    
    TTTipViewAnimationOptionNoScale            = 0 << 2,    //default
    TTTipViewAnimationOptionScaleIn            = 1 << 2,
    TTTipViewAnimationOptionScaleOut           = 2 << 2,
    TTTipViewAnimationOptionScaleInOut         = 3 << 2,
    
    TTTipViewAnimationOptionBounce             = 1 << 4,
    
    TTTipViewAnimationOptionGrowth             = 0 << 5,    //default, only used when has scale
    TTTipViewAnimationOptionShrink             = 1 << 5,
} TTTipViewAnimationOptions;

@interface TTTipView : UIView

+ (TTTipView *)tipViewWithType:(TTTipViewType)type;
+ (TTTipView *)currentTipView;
+ (void)dismissCurrentTipViewAnimated:(BOOL)animated;

@property (nonatomic) TTTipViewType tipType;

- (void)showInView:(UIView*)view animated:(BOOL)animated animationOptions:(TTTipViewAnimationOptions)options;

- (void)setText:(NSString *)text;

- (void)dismissAnimated:(BOOL)animated;

@end
