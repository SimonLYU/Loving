//
//  LOVEPixelView.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LOVEPixelView;
typedef NS_ENUM(NSUInteger, PixelType) {
    kPixelTypeAirportDefault = 1,
    kPixelTypeBattlefieldDefault,
    //我的战场上的状态
    kPixelTypeAirportDestroyHead,
    kPixelTypeAirportDestroyBody,
    kPixelTypeAirportMiss,
    //对方战场上的状态
    kPixelTypeBattlefieldDestoryHead,
    kPixelTypeBattlefieldDestoryBody,
    kPixelTypeBattlefieldMiss,
    //最后落子
    //我的战场上的状态
    kPixelTypeAirportLastFireDestroyHead,
    kPixelTypeAirportLastFireDestroyBody,
    kPixelTypeAirportLastFireMiss,
    //对方战场上的状态
    kPixelTypeBattlefieldLastFireDestoryHead,
    kPixelTypeBattlefieldLastFireDestoryBody,
    kPixelTypeBattlefieldLastFireMiss,
};

@protocol LOVEPixelViewDelegate<NSObject>

- (void)pixelView:(LOVEPixelView *)pixelView didSelectPosition:(CGPoint)position;

@end

@interface LOVEPixelView : UIView

@property (nonatomic, weak) id<LOVEPixelViewDelegate> delegate;

@property (nonatomic, assign , getter=isSelected) BOOL selected;
@property (nonatomic, assign) PixelType type;
@property (nonatomic, assign) CGPoint position;

@end
