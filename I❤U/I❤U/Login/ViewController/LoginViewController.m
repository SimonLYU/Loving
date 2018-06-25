//
//  LoginViewController.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/14.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LoginViewController.h"
#import "BaseHeaders.h"
#import "LoginViewModel.h"
#import "FDAlertView.h"
#import "ChallangeAlertView.h"
#import "UIColor+Extension.h"

@interface LoginViewController ()

@property (nonatomic, strong) LoginViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *loginIconImageView;

@property (nonatomic, strong) FDAlertView *challangeAlertView;

@end

@implementation LoginViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupData];
    [self _setupUI];
    [self registerRacsignal];
    
}
- (void)_setupData{
    self.accountTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLoginAccount];
    self.viewModel.account = self.accountTextField.text;
}
- (void)_setupUI{
    self.loginButton.layer.cornerRadius = 4;
    self.loginButton.layer.masksToBounds = YES;
    UITapGestureRecognizer * tapSelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfTap:)];
    [self.view addGestureRecognizer:tapSelf];
#ifdef WIFE_VERSION
    self.loginIconImageView.image = [UIImage imageNamed:@"AppIcon"];
    [self.registerButton setTitleColor:[UIColor ARGB:0x93D3DE] forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[UIColor ARGB:0xBDE8F7]];
    [self.loginButton setTitleColor:[UIColor ARGB:0x424242] forState:UIControlStateNormal];
    
    self.loginIconImageView.layer.cornerRadius = 0;
    self.loginIconImageView.layer.masksToBounds = NO;
#else
    self.loginIconImageView.image = [UIImage imageNamed:@"loginIcon-Plane"];
    [self.registerButton setTitleColor:[UIColor ARGB:0x90646F] forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[UIColor ARGB:0xAD5144]];
    [self.loginButton setTitleColor:[UIColor ARGB:0xEBEBEB] forState:UIControlStateNormal];
    
    self.loginIconImageView.layer.cornerRadius = 60;
    self.loginIconImageView.layer.masksToBounds = YES;
#endif
}
- (void)onSelfTap:(UITapGestureRecognizer *)tap{
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)registerRacsignal{
    [super registerRacsignal];
    //状态推导
    @weakify(self)
    RAC(self.viewModel , account) = [self.accountTextField.rac_textSignal map:^id(id value) {
        @strongify(self);
        NSString *finalStr = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (finalStr.length > 11) {
            finalStr = [finalStr substringToIndex:11];
            self.accountTextField.text = finalStr;
        }
        return finalStr;
    }];
    
    RAC(self.viewModel , password) = [self.passwordTextField.rac_textSignal map:^id(id value) {
        @strongify(self);
        NSString *finalStr = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (finalStr.length > 15) {
            finalStr = [finalStr substringToIndex:15];
            self.passwordTextField.text = finalStr;
        }
        return finalStr;
    }];
    
    [RACObserve(self.viewModel, isRegistering) subscribeNext:^(id x) {
        @strongify(self);
        self.passwordTextField.text = nil;
        if (self.viewModel.isRegistering) {//注册中按钮的状态
            self.passwordTextField.secureTextEntry = NO;
            [self.registerButton setTitle:@"已有账号?登录!" forState:UIControlStateNormal];
            [self.loginButton setTitle:@"注册" forState:UIControlStateNormal];
        }else{
            self.passwordTextField.secureTextEntry = YES;
            [self.registerButton setTitle:@"没有账号?注册!" forState:UIControlStateNormal];
            [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
        }
    }];
    
    [[self.registerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.viewModel.jumpRegisterCommand execute:nil];
    }];
    
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.viewModel.loginOrRegisterCommand execute:nil];
    }];
    
    [self.viewModel.loginOrRegisterCommand.executionSignals.flatten subscribeNext:^(id x) {
        BOOL isComplete = [x boolValue];
        if (isComplete) {
            [self showChallangeAlert];
        }
    }];
    
    [self.viewModel.creatConversationCommand.executionSignals.flatten subscribeNext:^(id x) {
        [self.challangeAlertView hide];
        [self.viewModel dismissViewModelAnimated:YES completion:nil];
    }];
}

- (void)showChallangeAlert{
    FDAlertView * alertView = [[FDAlertView alloc] init];
    self.challangeAlertView = alertView;
    [alertView setGrayBackgroupColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    ChallangeAlertView * challangeAlertContainView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(ChallangeAlertView.class) owner:nil options:nil].firstObject;
    @weakify(self);
    challangeAlertContainView.confirmBlock = ^(NSString * targetAccount){ //确认完成后
        @strongify(self);
        self.viewModel.targetAccount = targetAccount;
        [self.viewModel.creatConversationCommand execute:nil];
    };
    challangeAlertContainView.cancelBlock = ^(){
        @strongify(self);
        [self.challangeAlertView hide];
    };
    alertView.contentView = challangeAlertContainView;
    [alertView show];
}
@end
