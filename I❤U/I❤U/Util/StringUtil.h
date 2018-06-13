//
//  StringUtil.h
//  TTFoundation
//
//  Created by daixiang on 15/2/3.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NOT_NULL_STR(str) (str) ? (str) : @""

@interface StringUtil : NSObject

/**
 *  去掉字符串头尾的空格和换行
 */
+ (NSString *)trim:(NSString *)str;

/**
 *  去掉字符串头尾的空格和换行，并去掉中间的换行
 */
+ (NSString *)trimAndRemoveNewline:(NSString *)str;

+ (BOOL)isBlank:(NSString *)str;

+ (CGSize)calculateStringSize:(NSString *)str withFont:(UIFont *)font maxSize:(CGSize)size;

+ (NSString *)hexStringFromData:(NSData *)data;

/**
 * 判断字符串是不是数字 
 */
+ (BOOL)isNumber:(NSString *)str;



@end
