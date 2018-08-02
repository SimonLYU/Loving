//
//  FunctionFourViewModel.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/15.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseViewModel.h"

@interface FunctionFourViewModel : BaseViewModel

@property (nonatomic, copy) NSString *targetAccount;
@property (nonatomic, strong) RACCommand *creatConversationCommand;
@property (nonatomic, strong) RACCommand *testCommand;

@end
