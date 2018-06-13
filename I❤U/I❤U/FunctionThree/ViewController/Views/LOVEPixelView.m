//
//  LOVEPixelView.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LOVEPixelView.h"

@implementation LOVEPixelView

- (instancetype)init{
    if (self = [super init]) {
        UITapGestureRecognizer * tapSelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfSeleced:)];
        [self addGestureRecognizer:tapSelf];
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

@end
