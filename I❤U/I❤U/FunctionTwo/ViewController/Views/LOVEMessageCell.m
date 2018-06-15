//
//  LOVEMessageCell.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <HyphenateLite/HyphenateLite.h>
#import "LOVEMessageCell.h"
#import "LOVEMessage.h"
#import "BaseHeaders.h"
#import "IMManager.h"
#import "BaseHeaders.h"

@interface LOVEMessageCell()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromMeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeftCons;

@end

@implementation LOVEMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - setters
- (void)setMessage:(LOVEMessage *)message{
    _message = message;
    EMTextMessageBody *textBody = (EMTextMessageBody *)message.emMessage.body;
    NSString * text = textBody.text;
    
    self.fromMeLabel.hidden = YES;
    self.messageLabelLeftCons.constant = 5;
    
    if ([text hasPrefix:kStartScheme]) {
        text = [NSString stringWithFormat:@"%@ %@",[[IMManager shareManager] nickForAccount:message.emMessage.from],@"已准备"];
    }else if ([text hasPrefix:kEndScheme]){
        text = [NSString stringWithFormat:@"%@ %@",[[IMManager shareManager] nickForAccount:message.emMessage.from],@"重置了战场"];
    }else if ([text hasPrefix:kResetScheme]){
        text = [NSString stringWithFormat:@"%@ %@",[[IMManager shareManager] nickForAccount:message.emMessage.from],@"离开了房间"];
    }else if ([text hasPrefix:kFireScheme]){
        NSMutableString * pointText = [NSMutableString stringWithString:text];
        [pointText deleteCharactersInRange:NSMakeRange(0, kFireScheme.length)];
        text = [NSString stringWithFormat:@"%@ %@ %@",[[IMManager shareManager] nickForAccount:message.emMessage.from],@"攻击了",pointText];
    }else if ([text hasPrefix:kSysScheme]){
        NSMutableString * sysText = [NSMutableString stringWithString:text];
        [sysText deleteCharactersInRange:NSMakeRange(0, kSysScheme.length)];
        text = sysText;
    }else{
        if (message.isFromMe) {
            self.fromMeLabel.hidden = NO;
            self.messageLabelLeftCons.constant = 25;
        }else{
            self.fromMeLabel.hidden = YES;
            self.messageLabelLeftCons.constant = 5;
        }
    }
    self.messageLabel.text = text;
}

@end
