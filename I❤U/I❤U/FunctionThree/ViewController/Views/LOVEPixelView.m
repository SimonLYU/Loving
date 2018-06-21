//
//  LOVEPixelView.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseHeaders.h"
#import "LOVEPixelView.h"
#import "UIColor+Extension.h"
#import "LOTAnimationView+Extension.h"
#import "Masonry.h"
@interface LOVEPixelView()
@property (nonatomic, strong) LOTAnimationView *animationView;
@end

@implementation LOVEPixelView

- (instancetype)init{
    if (self = [super init]) {
        UITapGestureRecognizer * tapSelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfSeleced:)];
        [self addGestureRecognizer:tapSelf];
        @weakify(self);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyEnterForeground object:nil] subscribeNext:^(id x) {
            @strongify(self);
            [self resetAnimationView];
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
    if (selected) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = [UIColor whiteColor];
    }else{
        self.type = self.type;
    }
}

- (void)setType:(PixelType)type{
    _type = type;
    [self stopExplorerAnimation];
    
    switch (type) {
        case kPixelTypeAirportDefault:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor clearColor];
        }
            break;
        case kPixelTypeBattlefieldDefault:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4];
        }
            break;
        case kPixelTypeAirportDestroyHead:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor redColor];
        }
            break;
        case kPixelTypeAirportDestroyBody:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor yellowColor];
        }
            break;
        case kPixelTypeAirportMiss:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor blackColor];
        }
            break;
        case kPixelTypeBattlefieldDestoryHead:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor redColor];
        }
            break;
        case kPixelTypeBattlefieldDestoryBody:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor yellowColor];
        }
            break;
        case kPixelTypeBattlefieldMiss:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor blackColor];
        }
            break;
        case kPixelTypeAirportLastFireDestroyHead:
        {
            [self startExplorerAnimation];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor redColor];
        }
            break;
        case kPixelTypeAirportLastFireDestroyBody:
        {
            [self startExplorerAnimation];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor yellowColor];
        }
            break;
        case kPixelTypeAirportLastFireMiss:
        {
            [self startExplorerAnimation];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor blackColor];
        }
            break;
        case kPixelTypeBattlefieldLastFireDestoryHead:
        {
            [self startExplorerAnimation];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor redColor];
        }
            break;
        case kPixelTypeBattlefieldLastFireDestoryBody:
        {
            [self startExplorerAnimation];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor yellowColor];
        }
            break;
        case kPixelTypeBattlefieldLastFireMiss:
        {
            [self startExplorerAnimation];
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor blackColor];
        }
            break;
        default:
        {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 1;
            self.backgroundColor = [UIColor clearColor];
        }
            break;
    }
}

- (void)onSelfSeleced:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(pixelView:didSelectPosition:)]) {
        [self.delegate pixelView:self didSelectPosition:self.position];
    }
}

- (void)startExplorerAnimation{
    if (self.animationView) {
        [self.animationView play];
        return;
    }
    NSString * animationName = @"cover";
    NSString * rootDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LOTLocalResource"];
    self.animationView = [LOTAnimationView animationNamed:animationName rootDir:rootDir subDir:animationName];
    [self insertSubview:self.animationView atIndex:0];

    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(pixelWH);
        make.height.mas_equalTo(pixelWH);
    }];
    self.animationView.loopAnimation = YES;
    [self.animationView playWithCompletion:^(BOOL animationFinished) {
        [Log info:NSStringFromClass(self.class) message:@"动画播放完毕:%@",animationName];
    }];
}

- (void)stopExplorerAnimation{
    
    if (self.animationView) {
        [self.animationView stop];
        [self.animationView removeFromSuperview];
        self.animationView = nil;
        return;
    }
}

- (void)resetAnimationView{
    if (self.animationView) {
        [self.animationView play];
        return;
    }
}

@end
