//
//  FunctionFourViewModel.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/15.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <HyphenateLite/HyphenateLite.h>
#import "FunctionFourViewModel.h"
#import "LOVEModel.h"
#import "IMManager.h"

@implementation FunctionFourViewModel

- (void)initialize{
    [super initialize];
}

- (RACCommand *)creatConversationCommand{
    if (!_creatConversationCommand) {
        _creatConversationCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            if (!self.targetAccount ||
                [self.targetAccount isEqualToString:@""]) {
                [UIUtil showHint:@"请输入挑战者账号!"];
                return [RACSignal empty];
            }
            if ([self.targetAccount isEqualToString:LOVEModel.shareModel.toAccount]) {
                [UIUtil showHint:[NSString stringWithFormat:@"您和%@正在游戏中!",[[IMManager shareManager] nickForAccount:self.targetAccount]]];
                return [RACSignal empty];
            }
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                LOVEModel * loveModel = [LOVEModel shareModel];
                loveModel.conversation = [[EMClient sharedClient].chatManager getConversation:self.targetAccount type:EMConversationTypeChat createIfNotExist:YES];
                loveModel.toAccount = self.targetAccount;
                
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _creatConversationCommand;
}

@end
