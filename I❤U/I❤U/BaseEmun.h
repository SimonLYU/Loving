//
//  BaseEmun.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#ifndef BaseEmun_h
#define BaseEmun_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GULoadVC) {  //!< 定义加载VC的方式
    GULoadVCFromCode = 0,                //!< 创建纯代码vc
    GULoadVCFromXib,                     //!< 从xib创建VC
    GULoadVCFromStorybMain,              //!< 从main storyboard 初始
    GULoadVCFromStorybMember,            //!< 从Member storyboard 初始化
    GULoadVCFromStorybLogin,             //!< 从Login storyboard 初始化
};

#endif /* BaseEmun_h */
