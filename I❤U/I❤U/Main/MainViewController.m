//
//  MainViewController.m
//  I❤U
//
//  Created by 吕旭明 on 2018/3/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseHeaders.h"
#import "MainViewController.h"
#import "CoverView.h"
#import "BaseTabBarController.h"
#import "BaseNavigationController.h"
#import "FunctionOneViewModel.h"
#import "FunctionOneHomeViewController.h"
#import "FunctionTwoViewModel.h"
#import "FunctionTwoHomeViewController.h"
#import "FunctionThreeHomeViewController.h"
#import "FunctionThreeViewModel.h"
#import "FunctionFourHomeViewController.h"
#import "LOVEModel.h"
#import "LOVEViewModel.h"
#import "LOVELViewController.h"

typedef NS_ENUM(NSUInteger, ButtonTag) {
    kButtonTagFirst = 0,
    kButtonTagSecond,
    kButtonTagThird,
    kButtonTagForth,
    kButtonTagTotalCount,
};

typedef NS_ENUM(NSUInteger, CoverPostiton) {
    kCoverPositionIn,
    kCoverPositionOut,
};

#define BUTTON_WIDTH [UIScreen mainScreen].bounds.size.width * 0.5
#define BUTTON_HEIGHT [UIScreen mainScreen].bounds.size.height * 0.5
static CGFloat const maxScale = 3;
static CGFloat const coverAnimDuration = 0.25;

@interface MainViewController ()
//cover
@property (nonatomic, strong) CoverView *coverView;
@property (nonatomic, assign) CoverPostiton coverPosition;
@property (nonatomic, assign) CGFloat coverScale;
@property (nonatomic, strong) NSMutableArray *buttonList;
//mainTabController
@property (nonatomic, strong) BaseTabBarController *mainTabController;
//navigationController
@property (nonatomic, strong) BaseNavigationController *functionOneNavigationController;
@property (nonatomic, strong) BaseNavigationController *functionTwoNavigationController;
@property (nonatomic, strong) BaseNavigationController *functionThreeNavigationController;
@property (nonatomic, strong) BaseNavigationController *functionFourNavigationController;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupData];
    [self _setupMainTabController];
    [self _setupCoverSelectView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mainTabController.selectedIndex = 1;
}

#pragma mark - action
- (void)onTabButtonTapped:(UIButton *)button{
    switch (button.tag) {
        case kButtonTagFirst:
        {
            [Log info:NSStringFromClass(self.class) message:@"tabButton choose first"];
        }
            break;
        case kButtonTagSecond:
        {
            [Log info:NSStringFromClass(self.class) message:@"tabButton choose second"];
        }
            break;
        case kButtonTagThird:
        {
            [Log info:NSStringFromClass(self.class) message:@"tabButton choose third"];
        }
            break;
        case kButtonTagForth:
        {
            [Log info:NSStringFromClass(self.class) message:@"tabButton choose forth"];
        }
            break;
        default:
            break;
    }
    
    [self.mainTabController setSelectedIndex:button.tag];
    [self changeCoverViewPosition];
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch{
    self.coverView.hidden = NO;

    if (self.coverPosition == kCoverPositionIn) {//展示的时候
        if (pinch.scale < 1) {
            pinch.scale = 1;
        }
        self.coverScale = pinch.scale;
    }else if(self.coverPosition == kCoverPositionOut){//不展示的时候
        if (pinch.scale > 1) {
            pinch.scale = 1;
        }
        self.coverScale = pinch.scale;
    }
    
    switch (pinch.state) {
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:coverAnimDuration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                if (self.coverPosition == kCoverPositionIn) {//展示的时候
                    if (pinch.scale > 2) {
                        self.coverScale = 4;
                        self.coverPosition = kCoverPositionOut;
                    }else{
                        self.coverScale = 1;
                        self.coverPosition = kCoverPositionIn;
                    }
                }else if(self.coverPosition == kCoverPositionOut){//不展示的时候
                    if (pinch.scale < 0.7){
                        self.coverScale = 0;
                        self.coverPosition = kCoverPositionIn;
                    }else{
                        self.coverScale = 1;
                        self.coverPosition = kCoverPositionOut;
                    }
                }
            } completion:^(BOOL finished) {
                if (self.coverPosition == kCoverPositionIn) {//展示的时候
                    self.coverView.hidden = NO;
                }else if(self.coverPosition == kCoverPositionOut){//不展示的时候
                    self.coverView.hidden = YES;
                }
                
            }];
        }
            break;
        default:
            break;
    }
}
#pragma mark - notification
- (void)onCoverDoubleTapped:(NSNotification *)notification{
    [self changeCoverViewPosition];
}

- (void)onCoverScaleChanged:(NSNotification *)notification{
    [self pinchAction:notification.object];
}
#pragma mark - getter and setter
#pragma mark setter
- (void)setCoverScale:(CGFloat)coverScale
{
    //以最大4倍来计算
    _coverScale = coverScale;
    if (self.coverPosition == kCoverPositionIn) {
        coverScale = coverScale - 1;
        for (UIButton * tabButton in self.buttonList) {
            CGFloat xPos = 0;
            CGFloat yPos = 0;
            switch (tabButton.tag) {
                case kButtonTagFirst:
                {
                    xPos = -(coverScale * BUTTON_WIDTH / maxScale);
                    yPos = -(coverScale * BUTTON_HEIGHT / maxScale);
                }
                    break;
                case kButtonTagSecond:
                {
                    xPos = (coverScale * BUTTON_WIDTH / maxScale) + BUTTON_WIDTH;
                    yPos = -(coverScale * BUTTON_HEIGHT / maxScale);
                }
                    break;
                case kButtonTagThird:
                {
                    xPos = -(coverScale * BUTTON_WIDTH / maxScale);
                    yPos = (coverScale * BUTTON_HEIGHT / maxScale) + BUTTON_HEIGHT;
                }
                    break;
                case kButtonTagForth:
                {
                    xPos = (coverScale * BUTTON_WIDTH / maxScale) + BUTTON_WIDTH;
                    yPos = (coverScale * BUTTON_HEIGHT / maxScale) + BUTTON_HEIGHT;
                }
                    break;
                default:
                    break;
            }
            CGRect theFrame = tabButton.frame;
            theFrame.origin.x = xPos;
            theFrame.origin.y = yPos;
            tabButton.frame = theFrame;
        }
    }else if (self.coverPosition == kCoverPositionOut) {
        for (UIButton * tabButton in self.buttonList) {
            CGFloat xPos = 0;
            CGFloat yPos = 0;
            switch (tabButton.tag) {
                case kButtonTagFirst:
                {
                    xPos = -coverScale * BUTTON_WIDTH;
                    yPos = -coverScale * BUTTON_HEIGHT;
                }
                    break;
                case kButtonTagSecond:
                {
                    xPos = coverScale * BUTTON_WIDTH + BUTTON_WIDTH;
                    yPos = -coverScale * BUTTON_HEIGHT;
                }
                    break;
                case kButtonTagThird:
                {
                    xPos = -coverScale * BUTTON_WIDTH;
                    yPos = coverScale * BUTTON_HEIGHT + BUTTON_HEIGHT;
                }
                    break;
                case kButtonTagForth:
                {
                    xPos = coverScale * BUTTON_WIDTH + BUTTON_WIDTH;
                    yPos = coverScale * BUTTON_HEIGHT + BUTTON_HEIGHT;
                }
                    break;
                default:
                    break;
            }
            CGRect theFrame = tabButton.frame;
            theFrame.origin.x = xPos;
            theFrame.origin.y = yPos;
            tabButton.frame = theFrame;
        }
    }
}

#pragma mark - private
#pragma mark private init
- (void)_setupData{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCoverScaleChanged:) name:kCoverScaleChangeName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCoverDoubleTapped:) name:kCoverDoubleTapped object:nil];
    self.coverPosition = kCoverPositionIn;
    self.buttonList = [NSMutableArray array];
}
- (void)changeCoverViewPosition{
    self.coverView.hidden = NO;
    [UIView animateWithDuration:coverAnimDuration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.coverPosition == kCoverPositionIn) {//展示的时候
            self.coverScale = 4;
            self.coverPosition = kCoverPositionOut;
        }else if(self.coverPosition == kCoverPositionOut){//不展示的时候
            self.coverScale = 0;
            self.coverPosition = kCoverPositionIn;
        }
    } completion:^(BOOL finished) {
        if (self.coverPosition == kCoverPositionIn) {//展示的时候
            self.coverView.hidden = NO;
        }else if(self.coverPosition == kCoverPositionOut){//不展示的时候
            self.coverView.hidden = YES;
        }
    }];
}
#pragma mark private mainTabController
- (void)_setupMainTabController{
    self.mainTabController = [[BaseTabBarController alloc] init];
    self.mainTabController.tabBar.hidden = YES;
    
    FunctionOneViewModel * functionOneViewModel = [[FunctionOneViewModel alloc] initWithVCName:NSStringFromClass(FunctionOneHomeViewController.class) withInitType:GULoadVCFromXib];
    FunctionOneHomeViewController * functionOneHomeController = [functionOneViewModel loadedVC];
    BaseNavigationController * functionOneNavigation = [[BaseNavigationController alloc] initWithRootViewController:functionOneHomeController];
    [self.mainTabController addChildViewController:functionOneNavigation];
    
    FunctionTwoViewModel * functionTwoViewModel = [[FunctionTwoViewModel alloc] initWithVCName:NSStringFromClass(FunctionTwoHomeViewController.class) withInitType:GULoadVCFromXib];
    FunctionTwoHomeViewController * functionTwoHomeController = [functionTwoViewModel loadedVC];
    BaseNavigationController * functionTwoNavigation = [[BaseNavigationController alloc] initWithRootViewController:functionTwoHomeController];
    [self.mainTabController addChildViewController:functionTwoNavigation];
    
    FunctionThreeViewModel * funtionThreeViewModel = [[FunctionThreeViewModel alloc] initWithVCName:NSStringFromClass(FunctionThreeHomeViewController.class) withInitType:GULoadVCFromXib];
    FunctionThreeHomeViewController * functionThreeHomeController = [funtionThreeViewModel loadedVC];
    BaseNavigationController * functionThreeNavigation = [[BaseNavigationController alloc] initWithRootViewController:functionThreeHomeController];
    [self.mainTabController addChildViewController:functionThreeNavigation];
    
    FunctionFourHomeViewController * functionFourHomeController = [[FunctionFourHomeViewController alloc] initWithNibName:NSStringFromClass([FunctionFourHomeViewController class]) bundle:nil];
    BaseNavigationController * functionFourNavigation = [[BaseNavigationController alloc] initWithRootViewController:functionFourHomeController];
    [self.mainTabController addChildViewController:functionFourNavigation];
    
    self.functionOneNavigationController =  functionOneNavigation;
    self.functionTwoNavigationController = functionTwoNavigation;
    self.functionThreeNavigationController = functionThreeNavigation;
    self.functionFourNavigationController = functionFourNavigation;
    
    [self addChildViewController:self.mainTabController];
    [self.view addSubview:self.mainTabController.view];
}

#pragma mark private converSelectView
- (void)_setupCoverSelectView{
    CoverView * coverView = [[CoverView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    coverView.backgroundColor = [UIColor clearColor];
    self.coverView = coverView;
    [self.view addSubview:coverView];
    
    NSArray * buttonNameList = @[@"(￣▽￣)",@" (●ﾟωﾟ●)",@"(๑•̀ㅂ•́)و✧",@"O(∩_∩)O"];
    NSArray * buttonTagList = @[@(kButtonTagFirst),@(kButtonTagSecond),@(kButtonTagThird),@(kButtonTagForth)];
    for (int i = 0; i < buttonTagList.count; ++i) {
        CGFloat xPos = (i % 2) * BUTTON_WIDTH;
        CGFloat yPos = (i / 2) * BUTTON_HEIGHT;
        UIButton * tabButton = [[UIButton alloc] initWithFrame:CGRectMake(xPos, yPos, BUTTON_WIDTH, BUTTON_HEIGHT)];
        tabButton.tag = [buttonTagList[i] integerValue];
        [tabButton setTitle:buttonNameList[i] forState:UIControlStateNormal];
        [tabButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tabButton addTarget:self action:@selector(onTabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        tabButton.backgroundColor = [UIColor whiteColor];
        tabButton.layer.borderColor = [UIColor blackColor].CGColor;
        tabButton.layer.borderWidth = 1;
        [coverView addSubview:tabButton];
        [self.buttonList addObject:tabButton];
    }
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [coverView addGestureRecognizer:pinch];
}

@end
