//
//  UIColor+Extension.m
//  TT
//
//  Created by LiHong on 2016/10/13.
//  Copyright © 2016年 yiyou. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *)getColor:(NSString *)hexColor {
    NSString *string = nil;
    
    if ([hexColor hasPrefix:@"#"]){
       string = [hexColor substringFromIndex:1]; //去掉#号
    }else if ([hexColor hasPrefix:@"0x"]){
        string = [hexColor substringFromIndex:2]; //去掉0x号
    }else{
        string = hexColor;
    }
    if (string.length < 6){
        return nil;
    }
    
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    /* 调用下面的方法处理字符串 */
    red = [self stringToInt:[string substringWithRange:range]];
    
    range.location = 2;
    green = [self stringToInt:[string substringWithRange:range]];
    range.location = 4;
    blue = [self stringToInt:[string substringWithRange:range]];
    
    int alpha = 255;
    if (string.length == 8){
        range.location = 6;
        alpha = [self stringToInt:[string substringWithRange:range]];
    }
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:(float)(alpha/255.0f)];
}

+ (UIColor *)getARGBColor:(NSString *)hexColor {
    NSString *string = nil;
    
    if ([hexColor hasPrefix:@"#"]){
        string = [hexColor substringFromIndex:1]; //去掉#号
    }else if ([hexColor hasPrefix:@"0x"]){
        string = [hexColor substringFromIndex:2]; //去掉0x号
    }else{
        string = hexColor;
    }
    if (string.length < 6){
        return nil;
    }
    int alpha = 255;
    if (string.length == 8){
        
        
        unsigned int red,green,blue;
        NSRange range;
        range.length = 2;
        
        range.location = 0;
        alpha = [self stringToInt:[string substringWithRange:range]];
        
        /* 调用下面的方法处理字符串 */
        range.location = 2;
        red = [self stringToInt:[string substringWithRange:range]];
        
        range.location = 4;
        green = [self stringToInt:[string substringWithRange:range]];
        
        range.location = 6;
        blue = [self stringToInt:[string substringWithRange:range]];
        
        return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:(float)(alpha/255.0f)];
    }else{
        
        unsigned int red,green,blue;
        NSRange range;
        range.length = 2;
        
        range.location = 0;
        /* 调用下面的方法处理字符串 */
        red = [self stringToInt:[string substringWithRange:range]];
        
        range.location = 2;
        green = [self stringToInt:[string substringWithRange:range]];
        range.location = 4;
        blue = [self stringToInt:[string substringWithRange:range]];
        
        return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:(float)(alpha/255.0f)];
    }
    
   
 
}


+ (int)stringToInt:(NSString *)string {
    
    if (string == nil || string.length != 2){
        return 0;
    }
    unichar hex_char1 = [string characterAtIndex:0]; /* 两位16进制数中的第一位(高位*16) */
    int int_ch1;
    if (hex_char1 >= '0' && hex_char1 <= '9')
        int_ch1 = (hex_char1 - 48) * 16;   /* 0 的Ascll - 48 */
    else if (hex_char1 >= 'A' && hex_char1 <='F')
        int_ch1 = (hex_char1 - 55) * 16; /* A 的Ascll - 65 */
    else
        int_ch1 = (hex_char1 - 87) * 16; /* a 的Ascll - 97 */
    unichar hex_char2 = [string characterAtIndex:1]; /* 两位16进制数中的第二位(低位) */
    int int_ch2;
    if (hex_char2 >= '0' && hex_char2 <='9')
        int_ch2 = (hex_char2 - 48); /* 0 的Ascll - 48 */
    else if (hex_char2 >= 'A' && hex_char2 <= 'F')
        int_ch2 = hex_char2 - 55; /* A 的Ascll - 65 */
    else
        int_ch2 = hex_char2 - 87; /* a 的Ascll - 97 */
    return int_ch1+int_ch2;
}

+ (UIColor *)ARGB:(uint32_t)argb{
    CGFloat alpha = (argb & 0xFF000000) == 0 ? 1.0 : (CGFloat)(argb >> 24) / 255.0;
    CGFloat red = (CGFloat)((argb & 0x00FF0000) >> 16) / 255.0;
    CGFloat green = (CGFloat)((argb & 0x0000FF00) >> 8) / 255.0;
    CGFloat blue = (CGFloat)(argb & 0x000000FF) / 255.0;
    
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorForGuildLevel:(UInt32)level{
    switch (level) {
        case 1:
            return [UIColor ARGB:0xFFCA59];
        case 2:
            return [UIColor ARGB:0xC4E849];
        case 3:
            return [UIColor ARGB:0x83E652];
        case 4:
            return [UIColor ARGB:0x5FD881];
        case 5:
            return [UIColor ARGB:0x59C3A8];
        case 6:
            return [UIColor ARGB:0x64ABD9];
        case 7:
            return [UIColor ARGB:0x7796F8];
        case 8:
            return [UIColor ARGB:0xB875FC];
        case 9:
            return [UIColor ARGB:0xE55AF4];
        case 10:
            return [UIColor ARGB:0xF53971];
        default:
            return [UIColor whiteColor];
    }
}

@end
