//
//  LOVEPlaneView.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PlaneDiretion) {
    kPlaneDirectionUp = 1,
    kPlaneDirectionLeft,
    kPlaneDirectionDown,
    kPlaneDirectionRight,
};

@interface LOVEPlaneView : UIView

@property (nonatomic, strong) NSArray<NSArray *> *pixels;

@property (nonatomic, assign) PlaneDiretion planeDirection;

@property (nonatomic, assign) CGPoint position;

+ (LOVEPlaneView *)plane;

@end
