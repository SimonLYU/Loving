//
//  FunctionOneHomeViewController.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionOneHomeViewController.h"
#import "BaseHeaders.h"

@interface FunctionOneHomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
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
- (void)setupData{
    [[HttpUtil sharedInstance] getHttpRequestForPath:@"http://192.168.30.24:8080/hello" paras:nil completion:^(NSData *result, NSURLResponse *response, NSError *error) {
        if (error) {
            [Log info:NSStringFromClass(self.class) message:@"error = %@",error];
            return;
        }
        if (result) {
            NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
            if ([jsonDic objectForKey:@"message"]) {
                self.detailLabel.text = [jsonDic objectForKey:@"message"];
            }
            [Log info:NSStringFromClass(self.class) message:@"result json dict = %@",jsonDic];
        }else{
            [Log info:NSStringFromClass(self.class) message:@"result is nil!"];
        }
    }];
}

- (void)setupUI{
    self.detailLabel.text = @"暂时还没有想要说的话哦~";
}
@end
