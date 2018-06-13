//
//  FunctionOneViewModel.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseViewModel.h"
#import "BaseHeaders.h"

@interface FunctionOneViewModel : BaseViewModel

@property (nonatomic, copy) NSString *talkTitle;

@property (nonatomic, strong) RACCommand *talkTitleCommand;

@end
