
//
//  ConvenienceMacros.h
//  TTFoundation
//
//  Created by wuwei on 15/3/13.
//  Copyright (c) 2015年 yiyou. All rights reserved.
//

#ifndef TTFoundation_ConvenienceMacros_h
#define TTFoundation_ConvenienceMacros_h

#define dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }


#endif
