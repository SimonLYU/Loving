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

+ (CGFloat)calculateCellHeight:(EMMessage *)message;

- (void)genLocalGameMessage:(NSString *)text;

- (NSString *)nickForAccount:(NSString *)account;

@end
