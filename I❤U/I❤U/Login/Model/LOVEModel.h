//
//  LOVEModel.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EMConversation;

@interface LOVEModel : NSObject

//IM消息
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSString *fromAccount;
@property (nonatomic, strong) NSString *toAccount;

+ (LOVEModel *)shareModel;
    
@end
