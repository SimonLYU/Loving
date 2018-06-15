//
//  LOVELViewController.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseHeaders.h"
#import "LOVELViewController.h"
#import "LOVEViewModel.h"

@interface LOVELViewController ()

@property (nonatomic, strong) LOVEViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UIButton *wifeButton;
@property (weak, nonatomic) IBOutlet UIButton *husbandButton;

@end

@implementation LOVELViewController  
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerRacsignal];
}

- (void)registerRacsignal{
    [super registerRacsignal];
    self.wifeButton.rac_command = self.viewModel.loginCommand;
    self.husbandButton.rac_command = self.viewModel.loginCommand;
}


@end
