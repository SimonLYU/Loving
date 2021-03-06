//
//  LOVEModel.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LOVEModel.h"
#import <HyphenateLite/HyphenateLite.h>

@implementation LOVEModel

+ (LOVEModel *)shareModel{
    static LOVEModel * _shareModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareModel = [[LOVEModel alloc] init];
    });
    return _shareModel;
}

#pragma mark - setter
- (void)setConversation:(EMConversation *)conversation{
    if (_conversation) {
        self.lastConversation = _conversation;
    }
    _conversation = conversation;
    self.conversationId = conversation.conversationId;
}
- (void)setLastConversation:(EMConversation *)lastConversation{
    _lastConversation = lastConversation;
    self.lastConversationId = lastConversation.conversationId;
}

- (void)setToAccount:(NSString *)toAccount{
    if (_toAccount) {
        self.lastToAccount = _toAccount;
    }
    _toAccount = toAccount;
}

@end
