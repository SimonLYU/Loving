//
//  SystemUtil.m
//  TTFoundation
//
//  Created by daixiang on 15/2/4.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import "SystemUtil.h"
#import <UIKit/UIDevice.h>
#import <sys/utsname.h>

static NSString *JPTestBuildIDKey = @"JPTestBuildID_Key";
static NSString *JPTestEnableKey  = @"JPTest_Enable_Key";

@implementation SystemUtil

+ (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSInteger)appVersionCode {
    
#ifndef DISTRIBUTION
    
//    BOOL enableJPTest = [[NSUserDefaults standardUserDefaults] boolForKey:JPTestEnableKey];
//    if (enableJPTest) {
//        return [[NSUserDefaults standardUserDefaults] integerForKey:JPTestBuildIDKey];
//    }
    
#endif
    
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] integerValue];
}

+ (NSString *)appChannelId{
    id channel = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TTChannelId"];
    
    if (channel) {
        return channel;
    }else{
        return @"AppStore";
    }
}

+ (NSUInteger)clientVersion
{
    NSString *version = [SystemUtil appVersionString];
    NSArray *versionArray = [version componentsSeparatedByString:@"."];
    unsigned int versionInt = 0;
    if ([versionArray count] > 0) {
        versionInt |= ([versionArray[0] unsignedIntValue] << 24);
    }
    if ([versionArray count] > 1) {
        versionInt |= ([versionArray[1] unsignedIntValue] << 16);
    }
    if ([versionArray count] > 2) {
        versionInt |= ([versionArray[2] unsignedIntValue] << 0);
    }
    
    return versionInt;
}

+ (NSString*)deviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone9,1"]  || [deviceString isEqualToString:@"iPhone9,3"])     return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"]  || [deviceString isEqualToString:@"iPhone9,4"])     return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"] || [deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"] || [deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"] || [deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    if ([deviceString isEqualToString:@"i386"]       || [deviceString isEqualToString:@"x86_64"])         return @"iPhone Simulator";
    
    return deviceString;
}

+ (NSString *)appBundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
}

+ (BOOL)isOperatingSystemAtLeastVersion:(NSString *)version
{
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED)
    
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    return [sysVersion compare:version options:NSNumericSearch] != NSOrderedAscending;
    
#endif
    
    return NO;
}

+ (void)operatingSystemAtLeastVersion:(NSString *)version satisfied:(void(^)())satisfied otherwise:(void(^)())otherwise
{
    if ([self isOperatingSystemAtLeastVersion:version]) {
        if (satisfied) satisfied();
    } else {
        if (otherwise) otherwise();
    }
}

@end
