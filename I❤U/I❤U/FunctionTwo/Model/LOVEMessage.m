//
//  LOVEMessage.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LOVEMessage.h"
#import <HyphenateLite/HyphenateLite.h>

@implementation LOVEMessage

+ (LOVEMessage *)messageWithCellHeight:(CGFloat)cellHeight emMessage:(EMMessage *)emMessage{
    LOVEMessage * message = [[LOVEMessage alloc] init];
    message.messageCellHeight = cellHeight;
    message.emMessage = emMessage;
    return message;
}
- (BOOL)isFromMe{
    return [self.emMessage.from isEqualToString:[[EMClient sharedClient] currentUsername]];
}

@end
