//
//  DeviceUtil.m
//  TTFoundation
//
//  Created by daixiang on 15/1/27.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DeviceUtil.h"
#import "SSKeychain.h"
#import "Log.h"
#import "SimulateIDFA.h"
#import <AVFoundation/AVFoundation.h>
#import <AdSupport/AdSupport.h>
#import "ConvenienceMacros.h"
#include <sys/sysctl.h>

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

@implementation DeviceUtil

//+ (NSString *)deviceId {
//    static NSString *account = @"deviceId";
//    static dispatch_once_t onceToken;
//    static NSString *deviceId = nil;
//    dispatch_once(&onceToken, ^{
//        if (!deviceId) {
//            deviceId = [SSKeychain passwordForService:[NSBundle mainBundle].bundleIdentifier account:account];
//            if (!deviceId) {
//                deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
//                NSError *err = nil;
//                if (![SSKeychain setPassword:deviceId forService:[NSBundle mainBundle].bundleIdentifier account:account error:&err]) {
//                    [Log error:@"DeviceUtil" message:@"save device id failed: %@", err];
//                }
//            }
//        }
//    });
//    return deviceId;
//}
#pragma mark - lazyload
+ (NSString *)idfa{
    static NSString *idfa;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!idfa){
           idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        if (!idfa){
            idfa = [SimulateIDFA createSimulateIDFA];;
        }
    });
    return idfa;
}

+ (BOOL)isiPhoneX{
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (812 == size.width && 375 == size.height){
        return YES;
    }
    if (812 == size.height && 375 == size.width){
        return YES;
    }
    return NO;
}

+ (BOOL)isSmallScreen{
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (320 == size.width && 568 == size.height){
        return YES;
    }
    if (568 == size.height && 320 == size.width){
        return YES;
    }
    return NO;
}

+ (NSUUID *)getUUID {
    static NSString *account = @"UUID";
    static dispatch_once_t onceToken;
    static NSUUID *uuid = nil;
    dispatch_once(&onceToken, ^{
        
        if (!uuid) {
            NSString *value = [SSKeychain passwordForService:[NSBundle mainBundle].bundleIdentifier account:account];
            if (!value) {
                uuid = [UIDevice currentDevice].identifierForVendor;
                value = [UIDevice currentDevice].identifierForVendor.UUIDString;
                NSError *err = nil;
                if (![SSKeychain setPassword:value forService:[NSBundle mainBundle].bundleIdentifier account:account error:&err]) {
                    [Log error:@"DeviceUtil" message:@"save device id failed: %@", err];
                }
            } else {
                uuid = [[NSUUID alloc] initWithUUIDString:value];
            }
        }
    });
    return uuid;
}

+ (void)checkCameraAvailable:(void (^)(void))available denied:(void(^)(void))denied restriction:(void(^)(void))restriction
{
    available = available ? : ^{};
    denied = denied ? : ^{};
    restriction = restriction ? : ^{};
    
    if  ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // iOS7下，需要检查iPhone的隐私和访问限制项
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusAuthorized:
            {
                available();
                break;
            }
            case AVAuthorizationStatusDenied:
            {
                // [设置->隐私->相机]中禁止了YY访问相机
                denied();
                break;
            }
            case AVAuthorizationStatusRestricted:
            {
                // NOTE: 这个跟[设置-通用-访问限制]似乎没有关系
                restriction();
                break;
            }
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_main_sync_safe(^{
                        if (granted)
                        {
                            available();
                        }
                        else
                        {
                            denied();
                        }
                        
                    });
                    
                }];
            }
                
            default:
                break;
        }
    }
    else
    {
        restriction();
    }
}

+ (BOOL)hasHeadset {
    //模拟器不支持
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    AVAudioSessionRouteDescription *route = audioSession.currentRoute;
    //NSLog(@"current route input %@", route.inputs);
    //NSLog(@"current route output %@", route.outputs);
    ///NSLog(@"%@", AVAudioSessionPortHeadphones);
    for (AVAudioSessionPortDescription *desc in route.outputs) {
        
        NSRange headphoneRange = [desc.portType rangeOfString : @"Headphone"];
        NSRange headsetRange = [desc.portType rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound || headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
    
//    CFStringRef route;
//    UInt32 propertySize = sizeof(CFStringRef);
//    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
//    
//    if((route == NULL) || (CFStringGetLength(route) == 0)){
//        // Silent Mode
//        NSLog(@"AudioRoute: SILENT, do nothing!");
//    } else {
//        NSString* routeStr = (__bridge NSString*)route;
//        NSLog(@"AudioRoute: %@", routeStr);
//        
//        /* Known values of route:
//         * "Headset"
//         * "Headphone"
//         * "Speaker"
//         * "SpeakerAndMicrophone"
//         * "HeadphonesAndMicrophone"
//         * "HeadsetInOut"
//         * "ReceiverAndMicrophone"
//         * "Lineout"
//         */
//        
//        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
//        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
//        if (headphoneRange.location != NSNotFound) {
//            return YES;
//        } else if(headsetRange.location != NSNotFound) {
//            return YES;
//        }
//    }
    return NO;
#endif
    
}

//判断是否为越狱机
//以下为越狱文件
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

+ (BOOL)isJailBreak
{
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            return YES;//The device is NOT jail broken!
        }
    }
    return NO;//The device is NOT jail broken!
}

+ (NSString *)getSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getDeviceModel
{
    return [[UIDevice currentDevice] model];
}

+ (NSString *)getSystemType
{
    return [[UIDevice currentDevice] systemName];
}

+ (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

+ (BOOL)isSimulator {
#if TARGET_IPHONE_SIMULATOR
    return true;
#else
    return false;
#endif
}


@end
