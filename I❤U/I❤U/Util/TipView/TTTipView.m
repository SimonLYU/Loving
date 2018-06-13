//
//  TTTipView.m
//  TTFoundation
//
//  Created by daixiang on 15/8/1.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import "TTTipView.h"

#define GROWTH_SCALE_INITIAL_VALUE      0.8
#define SHRINK_SCALE_INITIAL_VALUE      2.0
#define GROWTH_BOUNCE_SCALE             1.2
#define SHRINK_BOUNCE_SCALE             0.8

//#define TTTIP_VIEW_TAG     29385781

//static int currentTipViewTag = TTTIP_VIEW_TAG;
static TTTipView *_currentTipView;

@interface TTTipView () {
//    TTTipViewType _tipType;
    BOOL _animated;
    TTTipViewAnimationOptions _animationOptions;
    NSTimer *_timeoutTimer;
}


@property (nonatomic) NSTimeInterval animationDuration;
//for hit & image, default YES, for loading, default NO
@property (nonatomic) BOOL shouldAutoDismiss;
//default: hit 2s, loading 30s, image 2s
@property (nonatomic) NSTimeInterval autoDismissDuration;

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) IBOutlet NSLayoutConstraint *spinnerTopConstraint;

@end

@implementation TTTipView

+ (TTTipView *)tipViewWithType:(TTTipViewType)type {
    
    CGRect bgFrame = [UIScreen mainScreen].bounds;
    TTTipView *tipView = [[TTTipView alloc] initWithFrame:bgFrame type:type];
    return tipView;
    
}

- (instancetype)initWithFrame:(CGRect)frame type:(TTTipViewType)type {

    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.shouldAutoDismiss = YES;
        self.animationDuration = 0.2;
        NSString *nibName = nil;
        _tipType = type;
        
        switch (type) {
            case TTTipViewTypeTextHint: {
                nibName = @"TTTextHintView";
                self.autoDismissDuration = 1;
                break;
            }
            case TTTipViewTypeLoading: {
                nibName = @"TTLoadingView";
                self.autoDismissDuration = 41; //比消息超时时间长一秒
                break;
             }
            default:
                break;
        }
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        UIView *view = [nib lastObject];
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:view];
        self.backgroundView.layer.cornerRadius = 8;
    }
    return self;
}

- (void)showInView:(UIView*)view animated:(BOOL)animated animationOptions:(TTTipViewAnimationOptions)options {
    
    _animated = animated;
    _animationOptions = options;
    
    TTTipView *tipView = [TTTipView currentTipView];
    if (tipView) {
        // 当前还有一个实例，dismiss当前的和显示新的，都不需要动画
        [TTTipView dismissCurrentTipViewAnimated:NO];
        animated = NO;
    }
    
//    currentTipViewTag = currentTipViewTag + 1;
//    self.tag = currentTipViewTag;
    self.frame = view.bounds;
    [view addSubview:self];
    _currentTipView = self;
    
    [self.spinner startAnimating];
    if (animated) {
        [self animatedShowOrHide:YES];
    }
    
    if (self.shouldAutoDismiss) {
        if (self.tipType == TTTipViewTypeTextHint) {
            // 这里改为根据文字长度设置显示时间
            NSTimeInterval dismissDuration = self.textLabel.text.length * 0.16;
            dismissDuration = dismissDuration < 0.8 ? 0.8 : dismissDuration; //最小时间
            dismissDuration = dismissDuration > 3 ? 3 : dismissDuration;     //最大时间
            _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:dismissDuration target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
        } else if (self.tipType == TTTipViewTypeLoading) {
            _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoDismissDuration target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
        }
    }
}

- (void)setText:(NSString *)text {
    
    self.textLabel.text = text;
    
    switch (_tipType) {
        case TTTipViewTypeTextHint: {
            CGSize size = [self.textLabel sizeThatFits:CGSizeMake(self.textLabel.frame.size.width, MAXFLOAT)];
            //NSLog(@"%f %f", size.width, size.height);
            
            CGFloat width = self.textLabel.bounds.size.width;
            CGFloat height = self.textLabel.bounds.size.height;
            CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 120;
            
            // 文字太长了，尝试扩充
            while (size.height > height) {
                
                width += 20;
                if (width > maxWidth) {
                    width = maxWidth;
                    height += 20;
                    
                    if (height > 300) {
                        height = 300;       // 高度上限
                        break;
                    }
                }
    
                size = [self.textLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
            }
            
            self.contentWidthConstraint.constant = width + 20;        // label左右10的padding
            self.contentHeightConstraint.constant = height + 20;      // label上下10的padding
            break;
        }
        case TTTipViewTypeLoading: {
            
            if ([text length] > 0) {
                self.spinnerTopConstraint.constant = 25;
                
                CGFloat oldlabelHeight = self.textLabel.frame.size.height;
                [self.textLabel sizeToFit];
                if (self.textLabel.frame.size.height > oldlabelHeight) {
                    self.contentHeightConstraint.constant += self.textLabel.frame.size.height - oldlabelHeight;
                }
                
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)dismissAnimated:(BOOL)animated {
    [self dismissAnimated:animated autoDismissed:NO];
}

+ (TTTipView *)currentTipView
{
//    TTTipView *tipView = (TTTipView *)[[UIApplication sharedApplication].keyWindow viewWithTag:currentTipViewTag];
//    return tipView;
    return _currentTipView;
}

+ (void)dismissCurrentTipViewAnimated:(BOOL)animated
{
    TTTipView *tipView = [TTTipView currentTipView];
//    NSLog(@"dismissloading %p", tipView);
    if (tipView)
    {
        [tipView dismissAnimated:animated];
    }
}

- (void)didMoveToSuperview {
    
//    NSLog(@"%p movetosuperview %p", self, self.superview);
    if (self.superview == nil && self == _currentTipView) {
        _currentTipView = nil;
    }
}

- (void)dealloc {
    
//    NSLog(@"tip dealloc %p", self);
}

#pragma mark - private

- (void)animatedShowOrHide:(BOOL)isShow
{
    BOOL shouldFade = _animationOptions & TTTipViewAnimationOptionFadeIn;
    BOOL shouldScale = _animationOptions & TTTipViewAnimationOptionScaleIn;
    BOOL shouldBounce = _animationOptions & TTTipViewAnimationOptionBounce;
    BOOL shouldShrink = _animationOptions & TTTipViewAnimationOptionShrink;
    
    if (isShow)
    {
        if (shouldFade)
        {
            self.contentView.alpha = 0;
        }
        if (shouldScale)
        {
            if (shouldShrink)
                self.contentView.transform = CGAffineTransformMakeScale(SHRINK_SCALE_INITIAL_VALUE, SHRINK_SCALE_INITIAL_VALUE);
            else
                self.contentView.transform = CGAffineTransformMakeScale(GROWTH_SCALE_INITIAL_VALUE, GROWTH_SCALE_INITIAL_VALUE);
        }
        NSTimeInterval duration = self.animationDuration;
        
        [UIView animateWithDuration:duration animations:^{
            if (shouldBounce)
            {
                if (shouldShrink)
                    self.contentView.transform = CGAffineTransformMakeScale(SHRINK_BOUNCE_SCALE, SHRINK_BOUNCE_SCALE);
                else
                    self.contentView.transform = CGAffineTransformMakeScale(GROWTH_BOUNCE_SCALE, GROWTH_BOUNCE_SCALE);
            }
            else
            {
                self.contentView.transform = CGAffineTransformIdentity;
            }
            self.contentView.alpha = 1;
        } completion:^(BOOL finished) {
            if (shouldBounce)
            {
                [UIView animateWithDuration:0.1 animations:^{
                    self.contentView.transform = CGAffineTransformIdentity;
                }];
            }
        }];
    }
    else
    {
        void (^block)(BOOL finished) = ^(BOOL finished) {
            [UIView animateWithDuration:self.animationDuration animations:^{
                if (shouldScale)
                {
                    self.contentView.transform = CGAffineTransformMakeScale(GROWTH_SCALE_INITIAL_VALUE, GROWTH_SCALE_INITIAL_VALUE);
                }
                else
                {
                    self.contentView.transform = CGAffineTransformIdentity;
                }
                if (shouldFade)
                {
                    self.contentView.alpha = 0;
                }
            } completion:^(BOOL finished) {
                
//                NSLog(@"animate hide complete %p", self);
                [self removeFromSuperview];
            }];
        };
        
        if (shouldBounce)
        {
            [UIView animateWithDuration:0.1 animations:^{
                self.contentView.transform = CGAffineTransformMakeScale(GROWTH_BOUNCE_SCALE, GROWTH_BOUNCE_SCALE);
            } completion:block];
        }
        else
        {
            block(YES);
        }
    }
}

- (void)timeout:(NSTimer *)timer {
    _timeoutTimer = nil;
    [self dismissAnimated:_animated autoDismissed:YES];
}

- (void)dismissAnimated:(BOOL)animated autoDismissed:(BOOL)autoDismissed
{
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    if (animated)
    {
        [self animatedShowOrHide:NO];
    }
    else
    {
        //NSLog(@"%p will call removefromsuperview", self);
        [self removeFromSuperview];
    }

}

@end
