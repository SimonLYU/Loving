//
//  ChallangeAlertView.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/14.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "ChallangeAlertView.h"
#import "BaseHeaders.h"

@interface ChallangeAlertView()


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) NSString *targetAccount;

@end

@implementation ChallangeAlertView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.containerView.layer.cornerRadius = 4;
    self.containerView.layer.masksToBounds = YES;
    [self registerRacsignals];
}
- (void)registerRacsignals{
    @weakify(self);
    RAC(self , targetAccount) = [self.textField.rac_textSignal map:^id(id value) {
        @strongify(self);
        NSString *finalStr = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (finalStr.length > 11) {
            finalStr = [finalStr substringToIndex:11];
            self.textField.text = finalStr;
        }
        return finalStr;
    }];
}

- (IBAction)onConfirmButtonClicked:(id)sender {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    if (self.confirmBlock) {
        self.confirmBlock(self.targetAccount);
    }
}
- (IBAction)onConcelButtonClicked:(id)sender {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end
