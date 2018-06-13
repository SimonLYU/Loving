//
//  UIColor+Extension.h
//  TT
//
//  Created by LiHong on 2016/10/13.
//  Copyright © 2016年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

+ (UIColor *)getColor:(NSString *)hexColor;

+ (UIColor *)getARGBColor:(NSString *)hexColor;

+ (UIColor *)ARGB:(uint32_t)argb;

+ (UIColor *)colorForGuildLevel:(UInt32)level;
@end
