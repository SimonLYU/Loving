//
//  LOVEPlaneView.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LOVEPlaneView.h"
#import "BaseHeaders.h"
#import "Masonry.h"

@implementation LOVEPlaneView

static NSInteger planeLength = 5;
static NSInteger planeHeight = 4;
+ (LOVEPlaneView *)plane{
    LOVEPlaneView * plane = [[LOVEPlaneView alloc] init];
    NSMutableArray * hangList = [NSMutableArray array];
    for (int hang = 0; hang < planeHeight; ++hang) {
        NSMutableArray * lieList = [NSMutableArray array];
        for (int lie = 0; lie < planeLength; ++lie) {
            UIView * pixel = [[UIView alloc] init];
            if ([self heightLightIfNeededWithPosition:CGPointMake(hang, lie)]) {
                pixel.layer.borderColor = [UIColor whiteColor].CGColor;
                pixel.layer.borderWidth = 1;
                pixel.backgroundColor = [UIColor whiteColor];
            }else{
                pixel.layer.borderColor = [UIColor clearColor].CGColor;
                pixel.layer.borderWidth = 1;
                pixel.backgroundColor = [UIColor clearColor];
            }

            pixel.frame = CGRectMake(lie * pixelWH, hang * pixelWH, pixelWH, pixelWH);
            [plane addSubview:pixel];
            [lieList insertObject:pixel atIndex:lie];
        }
        [hangList addObject:lieList];
    }
    plane.pixels = hangList;
    UITapGestureRecognizer * tapPlane = [[UITapGestureRecognizer alloc] initWithTarget:plane action:@selector(doRotation:)];
    [plane addGestureRecognizer:tapPlane];
    
    UIPanGestureRecognizer * panPlane = [[UIPanGestureRecognizer alloc] initWithTarget:plane action:@selector(onMove:)];
    [plane addGestureRecognizer:panPlane];
    return plane;
}

+ (BOOL)heightLightIfNeededWithPosition:(CGPoint)point{
    if (point.x == 1 ||//第二横排
        point.y == 2 ||//第三竖排
        (point.x == 3 && point.y != 0 && point.y != 4)) {//第四横排的指定点
        return YES;
    }
    return NO;
}

#pragma mark - setters
- (void)setPlaneDirection:(PlaneDiretion)planeDirection{
    _planeDirection = planeDirection;
    switch (planeDirection) {
        case kPlaneDirectionUp:
            self.transform = CGAffineTransformMakeRotation(0);
            break;
        case kPlaneDirectionRight:
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case kPlaneDirectionDown:
            self.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case kPlaneDirectionLeft:
            self.transform = CGAffineTransformMakeRotation(M_PI_2 * 3);
            break;
        default:
            break;
    }
    [self correctPosition];
}

#pragma mark - 粘性
- (void)correctPosition{
    CGRect correctFrame = self.frame;
    //粘性
    CGFloat remainder = 0;
    NSInteger xPos = self.frame.origin.x / pixelWH;
    remainder = (int)self.frame.origin.x % (int)pixelWH;
    if (remainder >= pixelWH * 0.5) {
        xPos++;
    }
    NSInteger yPos = self.frame.origin.y / pixelWH;
    remainder = (int)self.frame.origin.y % (int)pixelWH;
    if (remainder >= pixelWH * 0.5) {
        yPos++;
    }
    correctFrame.origin.x = xPos * pixelWH;
    correctFrame.origin.y = yPos * pixelWH;
    //边界
    if (self.frame.origin.x < 0) {
        correctFrame.origin.x = 0;
        xPos = 0;
    }else if (self.planeDirection == kPlaneDirectionLeft ||
              self.planeDirection == kPlaneDirectionRight) {
        if (correctFrame.origin.x > pixelWH * 6){
            correctFrame.origin.x = pixelWH * 6;
            xPos = 6;
        }
    }else{
        if (correctFrame.origin.x > pixelWH * 5){
            correctFrame.origin.x = pixelWH * 5;
            xPos = 5;
        }
    }

    if (correctFrame.origin.y < 0) {
        correctFrame.origin.y = 0;
        yPos = 0;
    }else if (self.planeDirection == kPlaneDirectionLeft ||
              self.planeDirection == kPlaneDirectionRight) {
        if (correctFrame.origin.y > pixelWH * 7){
            correctFrame.origin.y = pixelWH * 7;
            yPos = 7;
        }
    }else{
        if (correctFrame.origin.y > pixelWH * 8){
            correctFrame.origin.y = pixelWH * 8;
            yPos = 8;
        }
    }
    self.position = CGPointMake(xPos, yPos);
    self.frame = correctFrame;
}

#pragma mark - actions
- (void)doRotation:(id)sender{
    if (self.planeDirection >= 4) {
        self.planeDirection = 1;
    }else{
        self.planeDirection++;
    }
}

- (void)onMove:(UIPanGestureRecognizer *)pan{
    CGPoint pt = [pan translationInView:self];
    switch (self.planeDirection) {
        case kPlaneDirectionUp:
            pan.view.center = CGPointMake(pan.view.center.x + pt.x , pan.view.center.y + pt.y);
            break;
        case kPlaneDirectionRight:
            pan.view.center = CGPointMake(pan.view.center.x - pt.y , pan.view.center.y + pt.x);
            break;
        case kPlaneDirectionDown:
            pan.view.center = CGPointMake(pan.view.center.x - pt.x , pan.view.center.y - pt.y);
            break;
        case kPlaneDirectionLeft:
            pan.view.center = CGPointMake(pan.view.center.x + pt.y , pan.view.center.y - pt.x);
            break;
        default:
            break;
    }
    //每次移动完，将移动量置为0，否则下次移动会加上这次移动量
    [pan setTranslation:CGPointMake(0, 0) inView:self.superview];
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self correctPosition];
    }
}

@end
