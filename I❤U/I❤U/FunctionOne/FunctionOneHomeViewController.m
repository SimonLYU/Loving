//
//  FunctionOneHomeViewController.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionOneHomeViewController.h"

@interface FunctionOneHomeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FunctionOneHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
}

- (void)setupData{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = @"ceshi...";
    return cell;
}
#pragma mark - UITableViewDelegate
@end
