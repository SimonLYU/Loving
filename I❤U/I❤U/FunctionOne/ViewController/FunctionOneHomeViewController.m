//
//  FunctionOneHomeViewController.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionOneHomeViewController.h"
#import "BaseHeaders.h"
#import "Masonry.h"
#import "LOTAnimationView+Extension.h"
#import "FunctionOneViewModel.h"

@interface FunctionOneHomeViewController ()

@property (nonatomic, strong) FunctionOneViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) LOTAnimationView *animationView;

@end

@implementation FunctionOneHomeViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self registerRacsignal];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetAnimationView];
    [self setupData];
}

#pragma mark - private
- (void)setupUI{
    //navigationBar
    [self.navigationController.navigationBar setHidden:YES];
    //animation
    [self resetAnimationView];
    //label
    self.detailLabel.textColor = [UIColor whiteColor];
    self.detailLabel.text = @"暂时还没想好要说什么呢~";
}

- (void)registerRacsignal{
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyEnterForeground object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self resetAnimationView];
    }];
    
    [[RACObserve(self.viewModel, talkTitle) skip:1] subscribeNext:^(id x) {
        self.detailLabel.text = self.viewModel.talkTitle;
    }];
    
}

- (void)setupData{
    [self.viewModel.talkTitleCommand execute:nil];
}

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
