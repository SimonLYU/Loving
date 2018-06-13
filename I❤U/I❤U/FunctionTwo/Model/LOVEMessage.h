//
//  LOVEMessage.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <HyphenateLite/HyphenateLite.h>

@interface LOVEMessage : NSObject

@property (nonatomic, assign) CGFloat messageCellHeight;
@property (nonatomic, strong) EMMessage *emMessage;
@property (nonatomic, assign) BOOL isFromMe;

+ (LOVEMessage *)messageWithCellHeight:(CGFloat)cellHeight emMessage:(EMMessage *)emMessage;

@end
