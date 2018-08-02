//
//  FunctionFourHomeViewController.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionFourHomeViewController.h"
#import "FunctionFourViewModel.h"
#import "BaseHeaders.h"
#import "FDAlertView.h"
#import "ChallangeAlertView.h"
#import "IMManager.h"
#import "LOTAnimationView+Extension.h"
#import "Masonry.h"

@interface FunctionFourHomeViewController ()

@property (nonatomic, strong) FunctionFourViewModel *viewModel;

@property (nonatomic, strong) LOTAnimationView *animationView;
@property (nonatomic, strong) ChallangeAlertView *challangeView;

@end

@implementation FunctionFourHomeViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerRacsignal];
    [self setupUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetAnimationView];
    //ceshi...
    [self.viewModel.testCommand.executionSignals.flatten subscribeNext:^(id x) {
        
    }];
}

- (void)updateUI:(id)data data2:(id)data2{
    NSLog(@"data1 = %@, data2 = %@",data,data2);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.viewModel.testCommand execute:nil];
}

- (void)setupUI{
    //navigationBar
    [self.navigationController.navigationBar setHidden:YES];
    [self showChallangeAlert];
    
    UITapGestureRecognizer * tapSelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfTap:)];
    [self.view addGestureRecognizer:tapSelf];
}

- (void)onSelfTap:(UITapGestureRecognizer *)tap{
    if (self.challangeView && [self.challangeView.textField isFirstResponder]) {
        [self.challangeView.textField resignFirstResponder];
    }
}

- (void)registerRacsignal{
    [super registerRacsignal];
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyEnterForeground object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self resetAnimationView];
    }];
    
    [self.viewModel.creatConversationCommand.executionSignals.flatten subscribeNext:^(id x) {
        IMManager.shareManager.messageList = nil;
        IMManager.shareManager.gameMessageList = nil;
        [IMManager.shareManager.fetchServiceMessageListCommand execute:@(YES)];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationKeyChangeTargetAccount object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCoverDoubleTapped object:nil];
    }];
}

- (void)showChallangeAlert{
    ChallangeAlertView * challangeAlertContainView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(ChallangeAlertView.class) owner:nil options:nil].firstObject;
    @weakify(self);
    challangeAlertContainView.confirmBlock = ^(NSString * targetAccount){ //确认完成后
        @strongify(self);
        self.viewModel.targetAccount = targetAccount;
        [self.viewModel.creatConversationCommand execute:nil];
    };
    challangeAlertContainView.cancelBlock = ^(){
        [[NSNotificationCenter defaultCenter] postNotificationName:kCoverDoubleTapped object:nil];
    };
    [self.view addSubview:challangeAlertContainView];
    [challangeAlertContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.height.mas_equalTo(216);
        make.width.mas_equalTo(290);
    }];
    self.challangeView = challangeAlertContainView;
}

#pragma mark - UIGestureRecognizer

#pragma mark - private animation
- (void)resetAnimationView{
    if (self.animationView) {
        [self.animationView play];
        return;
    }
    NSString * animationName = @"starrysky_full";
    NSString * rootDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LOTLocalResource/RealTimeVoiceGame/Effect"];
    self.animationView = [LOTAnimationView animationNamed:animationName rootDir:rootDir subDir:animationName];
    [self.view insertSubview:self.animationView atIndex:0];
    CGFloat expectWidth = [UIScreen mainScreen].bounds.size.height*self.animationView.frame.size.width / self.animationView.frame.size.height;
    CGFloat expectHeight = [UIScreen mainScreen].bounds.size.width*self.animationView.frame.size.height / self.animationView.frame.size.width;
    //screen full
    if ([UIScreen mainScreen].bounds.size.height / self.animationView.frame.size.height > [UIScreen mainScreen].bounds.size.width / self.animationView.frame.size.width){
        expectHeight = [UIScreen mainScreen].bounds.size.height;
        expectWidth = expectHeight*self.animationView.frame.size.width / self.animationView.frame.size.height;
    }else{
        expectWidth = [UIScreen mainScreen].bounds.size.width;
        expectHeight = expectWidth*self.animationView.frame.size.height / self.animationView.frame.size.width;
    }
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(expectWidth);
        make.height.mas_equalTo(expectHeight);
    }];
    self.animationView.loopAnimation = YES;
    [self.animationView playWithCompletion:^(BOOL animationFinished) {
        [Log info:NSStringFromClass(self.class) message:@"动画播放完毕:%@",animationName];
    }];
}

@end
