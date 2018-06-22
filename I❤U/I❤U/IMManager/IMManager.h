//
//  IMManager.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/12.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHeaders.h"
@class EMMessage;

@interface IMManager : NSObject

@property (nonatomic, strong) NSArray *messageList;
@property (nonatomic, strong) NSArray *gameMessageList;

@property (nonatomic, strong) RACCommand *receiveNewMessageCommand;
@property (nonatomic, strong) RACCommand *fetchServiceMessageListCommand;

+ (IMManager *)shareManager;

/**
 * 根据message计算cell高度
 */
+ (CGFloat)calculateCellHeight:(EMMessage *)message;

/**
 * 在游戏界面生成一条不插入DB的系统提示消息
 */
- (void)genLocalGameMessage:(NSString *)text;

/**
 * 根据account获取hardcode昵称
 */
- (NSString *)nickForAccount:(NSString *)account;

/**
 * 查询account是否符合正则表达式kUserAccountRegiex
 */
- (BOOL)checkAccount:(NSString *)account;

@end
