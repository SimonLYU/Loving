//
//  StringUtil.m
//  TTFoundation
//
//  Created by daixiang on 15/2/3.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil

static const char khexCharTable[16] = {
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
};

+ (NSString *)trim:(NSString *)str {
    NSString *result = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
    return result;
}

+ (NSString *)trimAndRemoveNewline:(NSString *)str{
    NSString *result = [StringUtil trim:str];
    [result stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return result;
}



+ (BOOL)isBlank:(NSString *)str {
    return [[StringUtil trim:str] length] == 0;
}

+ (CGSize)calculateStringSize:(NSString *)str withFont:(UIFont *)font maxSize:(CGSize)size {
    
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName:font} context:nil];
    CGSize result = CGRectIntegral(rect).size;
    
    // boundingRectWithSize这个函数的计算会有一点偏差，需要加一点值
//    result = CGSizeMake(result.width+2, result.height+2);
    return result;
}

+ (NSString *)hexStringFromData:(NSData *)data
{
    unsigned char *bytes = (unsigned char *)[data bytes];
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:data.length * 2];
    for (int i = 0; i < data.length; ++i) {
        [buffer appendFormat:@"%c", khexCharTable[*bytes >> 4]];
        [buffer appendFormat:@"%c", khexCharTable[(*bytes++) & 0xf]];
    }
    
    return [buffer copy];
}

+ (BOOL)isNumber:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}



@end
