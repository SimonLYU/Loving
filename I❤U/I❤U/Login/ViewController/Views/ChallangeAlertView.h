//
//  ChallangeAlertView.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/14.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChallangeAlertView : UIView

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) dispatch_block_t cancelBlock;
@property (nonatomic, strong) void(^confirmBlock)(NSString * targetAccount);

@end
