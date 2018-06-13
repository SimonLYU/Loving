//
//  BaseViewController.m
//  I❤U
//
//  Created by 吕旭明 on 2018/3/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseHeaders.h"

@interface BaseViewController ()

@property (nonatomic, strong, readwrite) BaseViewModel *viewModel;

@end

@implementation BaseViewController

- (instancetype)initWithViewModel:(id)viewModel
{
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self _addKeyboardNotifications];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self _removeKeyboardNotifications];
}
- (void)dealloc{
    [self _removeKeyboardNotifications];
}

- (void)bandingViewModel:(id)viewModel
{
    self.viewModel = viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.view addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;//双击
    [self.view addGestureRecognizer:doubleTap];
}

#pragma mark - RAC
- (void)registerRacsignal{
    
}

#pragma mark - UIGestureRecognizer Action
- (void)pinchAction:(UIPinchGestureRecognizer *)pinch{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoverScaleChangeName object:pinch];
}

- (void)doubleTapped:(UITapGestureRecognizer *)tap{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCoverDoubleTapped object:tap];
}

#pragma mark - notification
- (void)_addKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)_removeKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)onKeyboardWillShow:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//
//    CGRect frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
//
//    [self keyboardWillShowWithFrameBegin:frameBegin frameEnd:frameEnd animationDuration:animationDuration animationCurve:animationCurve];
}

- (void)onKeyboardDidShow:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//
//    CGRect frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//
//    [self keyboardDidShowWithFrameBegin:frameBegin frameEnd:frameEnd];
}

- (void)onKeyboardWillHide:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//
//    CGRect frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
//
//    [self keyboardWillHideWithFrameBegin:frameBegin frameEnd:frameEnd animationDuration:animationDuration animationCurve:animationCurve];
}

- (void)onKeyboardDidHide:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//
//    CGRect frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//
//    [self keyboardDidHideWithFrameBegin:frameBegin frameEnd:frameEnd];
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//
//    CGRect frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
//
//    [self keyboardWillChangeFrameWithFrameBegin:frameBegin frameEnd:frameEnd animationDuration:animationDuration animationCurve:animationCurve];
}

- (void)onKeyboardDidChangeFrame:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//
//    CGRect frameBegin = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect frameEnd = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//
//    [self keyboardDidChangeFrameWithFrameBegin:frameBegin frameEnd:frameEnd];
}
@end
