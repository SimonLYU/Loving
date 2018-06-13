//
//  SystemUtil.h
//  TTFoundation
//
//  Created by daixiang on 15/2/4.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemUtil : NSObject

+ (NSString *)appVersionString;

+ (NSInteger)appVersionCode;

+ (NSUInteger)clientVersion;

+ (NSString*)deviceVersion;

+ (NSString *)appChannelId;

+ (NSString *)appBundleIdentifier;

+ (BOOL)isOperatingSystemAtLeastVersion:(NSString *)version;

+ (void)operatingSystemAtLeastVersion:(NSString *)version satisfied:(void(^)())satisfied otherwise:(void(^)())otherwise;

@end
