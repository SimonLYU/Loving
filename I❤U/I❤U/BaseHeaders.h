//
//  BaseHeaders.h
//  I❤U
//
//  Created by 吕旭明 on 2018/3/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#ifndef BaseHeaders_h
#define BaseHeaders_h
#import "BaseEmun.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/RACSignal.h>
#import <ReactiveCocoa/RACTuple.h>

#import "Log.h"
#import "HttpUtil.h"
#import "UIUtil.h"
/**
 * 由于 iOS 编译的特殊性，为了方便开发者使用，我们将 i386 x86_64 armv7 arm64 几个平台都合并到了一起
 * 所以使用动态库上传appstore时需要将i386 x86_64两个平台删除后，才能正常提交审核
 * 在SDK当前路径下执行以下命令删除i386 x86_64两个平台
 * bak文件是备份目录，上传appstore之后需要替换回bak目录下的SDK
 */
/*
mkdir ./bak
cp -r HyphenateLite.framework ./bak
lipo HyphenateLite.framework/HyphenateLite -thin armv7 -output HyphenateLite_armv7
lipo HyphenateLite.framework/HyphenateLite -thin arm64 -output HyphenateLite_arm64
lipo -create HyphenateLite_armv7 HyphenateLite_arm64 -output HyphenateLite
mv HyphenateLite HyphenateLite.framework/
 */

#define pixelWH (UIScreen.mainScreen.bounds.size.width * 0.1)

static NSString * const kCoverScaleChangeName    = @"coverScaleChange";
static NSString * const kCoverDoubleTapped       = @"coverDoubleTapped";

static NSString * const kNotificationKeyEneterBackground    = @"notificationKeyEneterBackground";
static NSString * const kNotificationKeyEnterForeground     = @"notificationKeyEnterForeground";

static NSString * const kNotificationKeyFire    = @"notificationKeyFire";
static NSString * const kNotificationKeyStart   = @"notificationKeyStart";
static NSString * const kNotificationKeyEnd     = @"notificationKeyEnd";

static NSString * const kFireScheme      = @"fire://";
static NSString * const kStartScheme     = @"start://";
static NSString * const kEndScheme       = @"end://";
static NSString * const kSysScheme       = @"sys://";

static NSString * const kPlaneBlank = @"0";
static NSString * const kPlaneBody  = @"1";
static NSString * const kPlaneHead  = @"2";

static NSInteger airportLength = 10;
static NSInteger airportHeight = 12;

static NSString * wifeAccount    = @"test1";
static NSString * husbandAccount = @"test2";

//static NSString * wifeAccount    = @"playerone";
//static NSString * husbandAccount = @"playertwo";

#endif /* BaseHeaders_h */
