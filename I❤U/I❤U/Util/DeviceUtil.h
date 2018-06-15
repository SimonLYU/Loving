//
//  DeviceUtil.h
//  TTFoundation
//
//  Created by daixiang on 15/1/27.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DeviceUtil : NSObject

+ (NSString *)idfa;
//+ (NSString *)deviceId;

+ (BOOL)isiPhoneX;

+ (BOOL)isSmallScreen;//5c等小屏幕

+ (NSUUID *)getUUID;

+ (void)checkCameraAvailable:(void (^)(void))available denied:(void(^)(void))denied restriction:(void(^)(void))restriction;

+ (BOOL)hasHeadset;

//判断是否为越狱机
+ (BOOL)isJailBreak;

//操作系统版本
+ (NSString *)getSystemVersion;

//机器型号
+ (NSString *)getDeviceModel;

//操作系统类型
+ (NSString *)getSystemType;


/**
 机器型号代码

 @return 机器型号代码
 */
+ (NSString *)machineModel;

/**
 判断是否模拟器

 */
+ (BOOL)isSimulator;

@end
