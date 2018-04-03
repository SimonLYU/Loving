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

@interface FunctionOneHomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) LOTAnimationView *animationView;

@end

@implementation FunctionOneHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
//    [self setupData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupData];
}
- (void)setupUI{
    //navigationBar
    [self.navigationController.navigationBar setHidden:YES];
    //animation
    if (!self.animationView) {
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
        self.animationView.loopAnimation = NO;
        [self.animationView playWithCompletion:^(BOOL animationFinished) {
            [Log info:NSStringFromClass(self.class) message:@"动画播放完毕:%@",animationName];
        }];
    }
    //label
    self.detailLabel.textColor = [UIColor whiteColor];
    self.detailLabel.text = @"暂时还没有想要说的话哦~";
}

- (void)setupData{
    __weak typeof(self) wSelf = self;
    [[HttpUtil sharedInstance] getHttpRequestForPath:@"http://192.168.80.201:8080/user/22" paras:nil completion:^(NSData *result, NSURLResponse *response, NSError *error) {
        if (error) {
            [Log info:NSStringFromClass(wSelf.class) message:@"error = %@",error];
            return;
        }
        if (result) {
            NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
            if ([jsonDic objectForKey:@"message"]) {
                wSelf.detailLabel.text = [jsonDic objectForKey:@"message"];
            }
            [Log info:NSStringFromClass(wSelf.class) message:@"result json dict = %@",jsonDic];
        }else{
            [Log info:NSStringFromClass(wSelf.class) message:@"result is nil!"];
        }
    }];
}
@end
