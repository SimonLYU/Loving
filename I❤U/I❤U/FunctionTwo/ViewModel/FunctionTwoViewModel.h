//
//  FunctionTwoViewModel.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseViewModel.h"
@class EMConversation;
@class EMMessage;

@interface FunctionTwoViewModel : BaseViewModel

@property (nonatomic, strong) NSString *inputMessage;

@property (nonatomic, strong) RACCommand *sendMessageCommand;

@end
