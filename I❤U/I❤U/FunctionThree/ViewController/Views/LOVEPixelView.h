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
    
    kPixelTypeAirportDestroyHead,
    kPixelTypeAirportDestroyBody,
    kPixelTypeAirportMiss,
    
    kPixelTypeBattlefieldDestoryHead,
    kPixelTypeBattlefieldDestoryBody,
    kPixelTypeBattlefieldMiss,
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
