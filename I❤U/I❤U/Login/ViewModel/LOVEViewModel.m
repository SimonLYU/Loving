//
//  LOVEViewModel.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LOVEViewModel.h"
#import "LOVEModel.h"
#import "FunctionTwoViewModel.h"
#import <HyphenateLite/HyphenateLite.h>

@implementation LOVEViewModel

- (void)initialize{
    [super initialize];
    
}

- (RACCommand *)loginCommand{
    if (!_loginCommand) {
        _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                UIButton * loginButton = (UIButton *)input;
                NSString * account = nil;
                NSString * toastString = nil;
                if (loginButton.tag == 1000) {
                    account = wifeAccount;
                    toastString = @"老婆";
                }else{
                    account = husbandAccount;
                    toastString = @"老公";
                }
                EMError *error = [[EMClient sharedClient] loginWithUsername:account password:@"1314"];
                if (!error) {
                    [Log info:NSStringFromClass(self.class) message:@"%@登录成功",toastString];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessKey" object:@{
                                                                                                           @"goNext" : @(YES),
                                                                                                           @"account" : loginButton.tag == 1000 ? husbandAccount : wifeAccount}];
                    LOVEModel * loveModel = [LOVEModel shareModel];
                    loveModel.conversation = [[EMClient sharedClient].chatManager getConversation:loginButton.tag == 1000 ? husbandAccount : wifeAccount type:EMConversationTypeChat createIfNotExist:YES];
                    loveModel.fromAccount = account;
                    loveModel.toAccount = loginButton.tag == 1000 ? husbandAccount : wifeAccount;
                    
                    [subscriber sendNext:@{
                                           @"goNext" : @(YES),
                                           @"account" : account
                                           }];
                    [subscriber sendCompleted];
                    [self dismissViewModelAnimated:YES completion:nil];
                }else{
                    [Log info:NSStringFromClass(self.class) message:@"%@登录失败",toastString];
                    [subscriber sendNext:@{
                                           @"goNext" : @(NO),
                                           @"account" : account
                                           }];
                    [subscriber sendCompleted];
                }
                
                return nil;
            }];
        }];
    }
    return _loginCommand;
}

@end
