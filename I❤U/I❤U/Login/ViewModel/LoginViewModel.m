//
//  LoginViewModel.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/14.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <HyphenateLite/HyphenateLite.h>
#import "BaseHeaders.h"
#import "LoginViewModel.h"
#import "LOVEModel.h"
#import "IMManager.h"

@implementation LoginViewModel
- (void)initialize{
    [super initialize];
}

- (RACCommand *)loginOrRegisterCommand{
    if (!_loginOrRegisterCommand) {
        _loginOrRegisterCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            if (!self.account ||
                !self.password ||
                [self.account isEqualToString:@""] ||
                [self.password isEqualToString:@""]) {
                [UIUtil showHint:@"请输入用户名或密码!"];
                return [RACSignal empty];
            }
            [UIUtil showLoadingWithText:@"请稍等..."];
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                if (self.isRegistering) {
                    //注册数量控制
                    NSInteger registerCount = [[[NSUserDefaults standardUserDefaults] objectForKey:kRegisterCount] integerValue];
                    if (registerCount >= 3) {
                        [UIUtil showHint:@"同一个设备最多注册三个账号哦!"];
                        [Log info:NSStringFromClass(self.class) message:@"%@注册失败,同一个设备最多注册三个账号 : %zd",self.account,registerCount];
                        [subscriber sendNext:@(NO)];
                        [subscriber sendCompleted];
                        return nil;
                    }
                    if (![IMManager.shareManager checkAccount:self.account]) {
                        [UIUtil showHint:@"用户名只能由3~16位小写字母和数字组成"];
                        [Log info:NSStringFromClass(self.class) message:@"用户名只能由3~16位小写字母和数字组成"];
                        [subscriber sendNext:@(NO)];
                        [subscriber sendCompleted];
                        return nil;
                    }
                    //注册
                    EMError *error = [[EMClient sharedClient] registerWithUsername:self.account password:self.password];
                    if (error==nil) {
                        [[NSUserDefaults standardUserDefaults] setObject:@(++registerCount) forKey:kRegisterCount];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }else{
                        [UIUtil showHint:@"用户名已被占用,换一个试试吧"];
                        [Log info:NSStringFromClass(self.class) message:@"%@注册失败,ERROR:%@ ",self.account,error.description];
                        [subscriber sendNext:@(NO)];
                        [subscriber sendCompleted];
                        return nil;
                    }
                }
                //登录 或 注册后直接登录
                if ([[EMClient sharedClient] isLoggedIn]) {
                    EMError *error = [[EMClient sharedClient] logout:YES];
                    if (!error) {
                        [Log info:NSStringFromClass(self.class) message:@"退出登录成功"];
                    }
                }
                
                EMError *error = [[EMClient sharedClient] loginWithUsername:self.account password:self.password];
                if (!error) {
                    [UIUtil dismissLoading];
                    [Log info:NSStringFromClass(self.class) message:@"%@登录成功",self.account];
                    [LOVEModel shareModel].fromAccount = self.account;
                    [[NSUserDefaults standardUserDefaults] setObject:self.account forKey:kLastLoginAccount];
                    [[NSUserDefaults standardUserDefaults] setObject:self.password forKey:kLastLoginPassword];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [subscriber sendNext:@(YES)];
                    [subscriber sendCompleted];
                }else{
                    [UIUtil showHint:@"登录失败,请检查用户名和密码"];
                    [Log info:NSStringFromClass(self.class) message:@"%@登录失败,ERROR:%@",self.account,error.description];
                    [subscriber sendNext:@(NO)];
                    [subscriber sendCompleted];
                }
                return nil;
            }];
        }];
    }
    return  _loginOrRegisterCommand;
}

- (RACCommand *)creatConversationCommand{
    if (!_creatConversationCommand) {
        _creatConversationCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            if (!self.targetAccount ||
                [self.targetAccount isEqualToString:@""]) {
                [UIUtil showHint:@"请输入挑战者账号!"];
                return [RACSignal empty];
            }
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                LOVEModel * loveModel = [LOVEModel shareModel];
                loveModel.conversation = [[EMClient sharedClient].chatManager getConversation:self.targetAccount type:EMConversationTypeChat createIfNotExist:YES];
                loveModel.toAccount = self.targetAccount;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessKey" object:nil];
                
                [self dismissViewModelAnimated:YES completion:nil];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _creatConversationCommand;
}

- (RACCommand *)jumpRegisterCommand{
    if (!_jumpRegisterCommand) {
        _jumpRegisterCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            self.isRegistering = !self.isRegistering;
            return [RACSignal empty];
        }];
    }
    return _jumpRegisterCommand;
}

@end
