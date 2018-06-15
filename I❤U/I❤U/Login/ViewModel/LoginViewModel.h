//
//  LoginViewModel.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/14.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseViewModel.h"

@interface LoginViewModel : BaseViewModel

@property (nonatomic, assign) BOOL isRegistering;

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *targetAccount;

@property (nonatomic, strong) RACCommand *loginOrRegisterCommand;
@property (nonatomic, strong) RACCommand *creatConversationCommand;
@property (nonatomic, strong) RACCommand *jumpRegisterCommand;

@end
