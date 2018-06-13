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

//#import "BaseViewModel.h"
//#import "BaseViewController.h"
//#import "BaseNavigationController.h"
//#import "BaseTabBarController.h"
#import "Log.h"
#import "HttpUtil.h"
#import "UIUtil.h"

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

static NSString * wifeAccount    = @"yyr";
static NSString * husbandAccount = @"lxm";

//static NSString * wifeAccount    = @"playerone";
//static NSString * husbandAccount = @"playertwo";

#endif /* BaseHeaders_h */
