//
//  FunctionThreeHomeViewController.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionThreeHomeViewController.h"
#import "BaseHeaders.h"
#import "LOVEViewModel.h"
#import "LOVELViewController.h"
#import "FunctionThreeViewModel.h"
#import "LOVEPlaneView.h"
#import "LOTAnimationView+Extension.h"
#import "Masonry.h"
#import "UIColor+Extension.h"
#import "LOVEPixelView.h"
#import "LOVEModel.h"
#import "IMManager.h"
#import "LOVEMessageCell.h"
#import "LOVEMessage.h"
#import "LOVEGameAudioManager.h"

@interface FunctionThreeHomeViewController ()<LOVEPixelViewDelegate , UITableViewDelegate , UITableViewDataSource>

@property (nonatomic, strong) FunctionThreeViewModel *viewModel;

@property (nonatomic, strong) LOTAnimationView *animationView;

@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *fireButton;

@property (strong, nonatomic) UIView *airportView;
@property (strong, nonatomic) UIView *battleView;
@property (weak, nonatomic) IBOutlet UITableView *systemTableView;

@property (weak, nonatomic) IBOutlet UIScrollView *battleFieldScrollView;
@property (nonatomic, strong) NSArray<NSArray *> *airportPixels;
@property (nonatomic, strong) NSArray<NSArray *> *battlefieldPixels;

@end

@implementation FunctionThreeHomeViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupUI];
    [self _setupLoginView];
    [self registerRacsignal];
    
    [IMManager.shareManager.fetchServiceMessageListCommand execute:@(NO)];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetAnimationView];
}

#pragma mark - LOVEPixelViewDelegate
- (void)pixelView:(LOVEPixelView *)pixelView didSelectPosition:(CGPoint)position{
    [LOVEGameAudioManager playUIAudio:kGameRoomUIAudioTypeClickEnableButton];
    for (NSArray * hangs in self.battlefieldPixels) {
        for (LOVEPixelView * pixel in hangs) {
            pixel.selected = NO;
        }
    }
    pixelView.selected = !pixelView.selected;
    self.viewModel.targetPoint = position;
}

#pragma mark - setupUI
- (void)_setupUI{
    //navigationBar
    [self.navigationController.navigationBar setHidden:YES];
    
    [self.systemTableView registerNib:[UINib nibWithNibName:NSStringFromClass(LOVEMessageCell.class) bundle:nil] forCellReuseIdentifier:@"messageCell"];
    self.systemTableView.delegate = self;
    self.systemTableView.dataSource = self;
    
    [self resetAnimationView];
    [self setupAirport];
    [self setupSystemTableView];
    [self setupBattleView];
    [self setupBattleFieldScrollView];
}

- (void)setupSystemTableView{
    self.systemTableView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.systemTableView.layer.borderWidth = 1;
    self.systemTableView.layer.cornerRadius = 5;
    self.systemTableView.layer.masksToBounds = YES;
}

- (void)setupBattleFieldScrollView{
    self.battleFieldScrollView.contentSize = CGSizeMake(pixelWH * airportLength * 2, pixelWH * airportHeight);
    self.battleFieldScrollView.pagingEnabled = YES;
}

- (void)setupAirport{
    self.airportView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pixelWH * airportLength, pixelWH * airportHeight)];
    self.airportView.backgroundColor = [UIColor clearColor];
    [self.battleFieldScrollView addSubview:self.airportView];
    
    NSMutableArray * hangList = [NSMutableArray array];
    for (int hang = 0; hang < airportHeight; ++hang) {
        NSMutableArray * lieList = [NSMutableArray array];
        for (int lie = 0; lie < airportLength; ++lie) {
            LOVEPixelView * pixel = [[LOVEPixelView alloc] init];
            pixel.type = kPixelTypeAirportDefault;
            pixel.frame = CGRectMake(lie * pixelWH, hang * pixelWH, pixelWH, pixelWH);
            pixel.position = CGPointMake(hang, lie);
            pixel.userInteractionEnabled = NO;
            [self.airportView addSubview:pixel];
            [lieList insertObject:pixel atIndex:lie];
        }
        [hangList addObject:lieList];
    }
    self.airportPixels = hangList;
}
- (void)setupBattleView{
    self.battleView = [[UIView alloc] initWithFrame:CGRectMake(pixelWH * airportLength, 0, pixelWH * airportLength, pixelWH * airportHeight)];
    self.battleView.backgroundColor = [UIColor clearColor];
    [self.battleFieldScrollView addSubview:self.battleView];
    
    NSMutableArray * hangList = [NSMutableArray array];
    for (int hang = 0; hang < airportHeight; ++hang) {
        NSMutableArray * lieList = [NSMutableArray array];
        for (int lie = 0; lie < airportLength; ++lie) {
            LOVEPixelView * pixel = [[LOVEPixelView alloc] init];
            pixel.type = kPixelTypeBattlefieldDefault;
            pixel.frame = CGRectMake(lie * pixelWH, hang * pixelWH, pixelWH, pixelWH);
            pixel.position = CGPointMake(hang, lie);
            pixel.delegate = self;
            [self.battleView addSubview:pixel];
            [lieList insertObject:pixel atIndex:lie];
        }
        [hangList addObject:lieList];
    }
    self.battlefieldPixels = hangList;
}
#pragma mark - RAC
- (void)registerRacsignal{
    //editing 状态变化
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyEnterForeground object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self resetAnimationView];
    }];
    
    [RACObserve(self.viewModel, isEditing) subscribeNext:^(id x) {
        @strongify(self);
        if (self.viewModel.isEditing) {
            self.airportView.userInteractionEnabled = YES;
            [self.readyButton setTitle:@"减少飞机" forState:UIControlStateNormal];
            [self.endButton setTitle:@"增加飞机" forState:UIControlStateNormal];
            [self.editButton setTitle:@"完成" forState:UIControlStateNormal];
            self.fireButton.hidden = YES;
        }else{
            [self.readyButton setTitle:@"准备" forState:UIControlStateNormal];
            [self.endButton setTitle:@"结束/重置" forState:UIControlStateNormal];
            [self.editButton setTitle:@"布阵" forState:UIControlStateNormal];
            self.fireButton.hidden = NO;
            self.airportView.userInteractionEnabled = NO;
        }
    }];
    
    [[RACObserve(IMManager.shareManager, gameMessageList) skip:1] subscribeNext:^(id x) {
        [self.systemTableView reloadData];
        [self scrollToBottom];
    }];
    
    [RACObserve(self.viewModel, iAmReady) subscribeNext:^(id x) {
        if (self.viewModel.iAmReady && self.viewModel.targetIsReady) {
            [self.readyButton setTitle:@"游戏中..." forState:UIControlStateDisabled];
            [self.editButton setTitle:@"游戏中..." forState:UIControlStateDisabled];
        }else{
            [self.readyButton setTitle:@"已准备" forState:UIControlStateDisabled];
            [self.editButton setTitle:@"已准备" forState:UIControlStateDisabled];
        }
        if (self.viewModel.iAmReady) {
            self.readyButton.enabled = NO;
            self.editButton.enabled = NO;
        }else{
            self.readyButton.enabled = YES;
            self.editButton.enabled = YES;
        }
    }];
    [RACObserve(self.viewModel, targetIsReady) subscribeNext:^(id x) {
        if (self.viewModel.iAmReady && self.viewModel.targetIsReady) {
            [self.readyButton setTitle:@"游戏中..." forState:UIControlStateDisabled];
            [self.editButton setTitle:@"游戏中..." forState:UIControlStateDisabled];
        }else{
            [self.readyButton setTitle:@"已准备" forState:UIControlStateDisabled];
            [self.editButton setTitle:@"已准备" forState:UIControlStateDisabled];
        }
    }];
    
    [RACObserve(self.viewModel, myDestroyPoints) subscribeNext:^(id x) {
        [self updateAirport];
    }];
    
    [RACObserve(self.viewModel, targetDestroyPoints) subscribeNext:^(id x) {
        [self updateBattleField];
    }];
    
    [IMManager.shareManager.fetchServiceMessageListCommand.executionSignals.flatten subscribeNext:^(id x) {
        [self scrollToBottom];
    }];
    
    
    [self.viewModel.endOrAddCommand.executionSignals.flatten subscribeNext:^(id x) {
        @strongify(self);
        [self updateAirport];
    }];
    [self.viewModel.readyOrRemoveCommand.executionSignals.flatten subscribeNext:^(id x) {
        @strongify(self);
        [self updateAirport];
    }];
    
    [[self.editButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel.editOrFinishCommand execute:nil];
    }];
    
    [[self.readyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel.readyOrRemoveCommand execute:nil];
    }];
    
    [[self.endButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel.endOrAddCommand execute:nil];
    }];
    
    [[self.fireButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel.fireCommand execute:nil];
    }];
    
}
- (void)scrollToBottom{
    if (IMManager.shareManager.gameMessageList.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[IMManager.shareManager.gameMessageList count]-1 inSection:0];
        [self.systemTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        self.findNewMessageButton.hidden = YES;
    }
}

#pragma mark - tableviewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return IMManager.shareManager.gameMessageList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LOVEMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    
    LOVEMessage *loveMessage = IMManager.shareManager.gameMessageList[indexPath.row];
    cell.message = loveMessage;
    return cell;
}

#pragma mark - tableviewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 28;
}

#pragma mark - private loginView
- (void)resetAirport{
    for (NSArray  * lies in self.airportPixels) {
        for (LOVEPixelView * pixel in lies) {
            pixel.type = kPixelTypeAirportDefault;
        }
    }
}
- (void)resetBattlefield{
    for (NSArray  * lies in self.battlefieldPixels) {
        for (LOVEPixelView * pixel in lies) {
            pixel.type = kPixelTypeBattlefieldDefault;
        }
    }
}
- (void)updateBattleField{
    [self resetBattlefield];
    self.viewModel.targetDestroyCount = 0;
    for (NSString * pointString in self.viewModel.targetDestroyPoints) {
        NSInteger targetHang = [[pointString componentsSeparatedByString:@","].firstObject integerValue];
        NSInteger targetLie = [[pointString componentsSeparatedByString:@","].lastObject integerValue];
        
        LOVEPixelView * pixel = self.battlefieldPixels[targetHang][targetLie];
        NSString * mapString = self.viewModel.targetPlanesMap[targetHang][targetLie];
        if ([mapString isEqualToString:kPlaneBody]) {
            pixel.type = kPixelTypeBattlefieldDestoryBody;
        }else if ([mapString isEqualToString:kPlaneHead]){
            self.viewModel.targetDestroyCount++;
            pixel.type = kPixelTypeBattlefieldDestoryHead;
        }else if ([mapString isEqualToString:kPlaneBlank]){
            pixel.type = kPixelTypeBattlefieldMiss;
        }
    }
}
- (void)updateAirport{
    [self resetAirport];
    self.viewModel.myDestroyCount = 0;
    for (NSString * pointString in self.viewModel.myDestroyPoints) {
        NSInteger targetHang = [[pointString componentsSeparatedByString:@","].firstObject integerValue];
        NSInteger targetLie = [[pointString componentsSeparatedByString:@","].lastObject integerValue];
        
        LOVEPixelView * pixel = self.airportPixels[targetHang][targetLie];
        NSString * mapString = self.viewModel.myPlanesMap[targetHang][targetLie];
        if ([mapString isEqualToString:kPlaneBody]) {
            pixel.type = kPixelTypeAirportDestroyBody;
        }else if ([mapString isEqualToString:kPlaneHead]){
            self.viewModel.myDestroyCount++;
            pixel.type = kPixelTypeAirportDestroyHead;
        }else if ([mapString isEqualToString:kPlaneBlank]){
            pixel.type = kPixelTypeAirportMiss;
        }
    }
    
    for (UIView * subview in self.airportView.subviews) {
        if ([subview isKindOfClass:[LOVEPlaneView class]]) {
            [subview removeFromSuperview];
        }
    }
    for (LOVEPlaneView * plane in self.viewModel.planeList) {
        [self.airportView insertSubview:plane atIndex:0];
    }
}
- (void)_setupLoginView{
    if (![LOVEModel shareModel].conversation) {
        LOVEViewModel * loginViewModel = [[LOVEViewModel alloc] initWithVCName:NSStringFromClass(LOVELViewController.class) withInitType:GULoadVCFromXib];
        [self.viewModel presentViewModel:loginViewModel animated:NO completion:nil];
    }
}
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
