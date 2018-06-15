//
//  FunctionTwoHomeViewController.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/8.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <HyphenateLite/HyphenateLite.h>
#import "BaseHeaders.h"
#import "FunctionTwoHomeViewController.h"
#import "FunctionTwoViewModel.h"
#import "LOVEViewModel.h"
#import "LOVELViewController.h"
#import "LOVEMessageCell.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "LOVEMessage.h"
#import "LOTAnimationView+Extension.h"
#import "Masonry.h"
#import "UIColor+Extension.h"
#import "LOVEModel.h"
#import "IMManager.h"
#import "LoginViewModel.h"
#import "LoginViewController.h"

#define MAX_INPUTVIEW_HEIGHT 100
#define MIN_INPUTVIEW_HEIGHT 45

@interface FunctionTwoHomeViewController ()<UITableViewDelegate , UITableViewDataSource ,UITextViewDelegate>

@property (nonatomic, strong) LOTAnimationView *animationView;

@property (weak, nonatomic) IBOutlet UIButton *findNewMessageButton;
@property (nonatomic, strong) FunctionTwoViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewHeightCons;

@end

@implementation FunctionTwoHomeViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupUI];
    [self _setupLoginView];
    [self registerRacsignal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetAnimationView];
}

- (void)scrollToBottom{
    if (IMManager.shareManager.messageList.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[IMManager.shareManager.messageList count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        self.findNewMessageButton.hidden = YES;
    }
}

- (void)registerRacsignal{
    [super registerRacsignal];
    RAC(self.viewModel , inputMessage) = [self.inputTextView.rac_textSignal map:^id(id value) {
        return value;
    }];
    [RACObserve(self.viewModel, inputMessage) subscribeNext:^(id x) {
        self.inputTextView.text = self.viewModel.inputMessage;
    }];
    [[RACObserve(IMManager.shareManager, messageList) skip:1] subscribeNext:^(id x) {
        [self.tableView reloadData];
        
        CGFloat maxScrollY = self.tableView.contentSize.height - self.tableView.bounds.size.height + self.tableView.contentInset.bottom;
        if ((maxScrollY <= 0) || (maxScrollY > 0 && (maxScrollY-self.tableView.contentOffset.y) < self.tableView.bounds.size.height * 1.5)) {
            [self scrollToBottom];
        }else{
            self.findNewMessageButton.hidden = NO;
        }
    }];
    [IMManager.shareManager.fetchServiceMessageListCommand.executionSignals.flatten subscribeNext:^(id x) {
        [self scrollToBottom];
    }];
    [[self.findNewMessageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self scrollToBottom];
    }];
    [RACObserve(self.inputTextView, contentSize) subscribeNext:^(id x) {
        CGSize newContentSize = self.inputTextView.contentSize;
        [Log info:NSStringFromClass(self.class) message:@"x = %@",x];
        UITextView *textView = self.inputTextView;
        CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
        if (contentOffsetToShowLastLine.y > 0) {
            textView.contentOffset = contentOffsetToShowLastLine;
        } else {
            textView.contentOffset = CGPointMake(0, 0);
        }
        
        CGFloat targetHeight = newContentSize.height + 10;
        if (targetHeight > MAX_INPUTVIEW_HEIGHT){
            self.inputViewHeightCons.constant = MAX_INPUTVIEW_HEIGHT;
        }else if (targetHeight > MIN_INPUTVIEW_HEIGHT) {
            self.inputViewHeightCons.constant = targetHeight;
        }else{
            self.inputViewHeightCons.constant = MIN_INPUTVIEW_HEIGHT;
        }
        
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        CGFloat tableViewMaxY = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        if (tableViewMaxY > 0)
        {
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, tableViewMaxY);
        }
        
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
        
    }];
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kCoverScaleChangeName object:nil] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.inputTextView isFirstResponder]) {
            [self.inputTextView resignFirstResponder];
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kCoverDoubleTapped object:nil] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.inputTextView isFirstResponder]) {
            [self.inputTextView resignFirstResponder];
        }
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationKeyEnterForeground object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self resetAnimationView];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationLoginSuccessKey object:nil] subscribeNext:^(id x) {
        [IMManager.shareManager.fetchServiceMessageListCommand execute:@(YES)];
    }];
}

- (void)_setupUI{
    [self.navigationController setNavigationBarHidden:YES];
    //animation
    [self resetAnimationView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(LOVEMessageCell.class) bundle:nil] forCellReuseIdentifier:@"messageCell"];
    
    self.inputTextView.delegate = self;
    self.inputTextView.layer.cornerRadius = 2;
    self.inputTextView.layer.masksToBounds = YES;
    self.inputTextView.layer.borderColor = [UIColor ARGB:0xEBEBEB].CGColor;
    self.inputTextView.layer.borderWidth = 1;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableViewTapped:)];
    [self.tableView addGestureRecognizer:tap];
    
}

#pragma mark - textViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self sendPressed];
        return NO;
    }
    
    return YES;
}

#pragma mark - tableviewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return IMManager.shareManager.messageList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LOVEMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    
    LOVEMessage *loveMessage = IMManager.shareManager.messageList[indexPath.row];
    cell.message = loveMessage;
    return cell;
}

#pragma mark - tableviewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LOVEMessage *loveMessage = IMManager.shareManager.messageList[indexPath.row];
    if (loveMessage.messageCellHeight <= 0) {
        loveMessage.messageCellHeight = [IMManager.class calculateCellHeight:loveMessage.emMessage];
    }
    return loveMessage.messageCellHeight;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([scrollView isMemberOfClass:[UITableView class]]){
        if (self.tableView.contentOffset.y + self.tableView.bounds.size.height >= self.tableView.contentSize.height) {
            self.findNewMessageButton.hidden = YES;
        }
    }
}

#pragma mark - UIGestureRecognizer
- (void)onTableViewTapped:(UITapGestureRecognizer *)tap{
    if ([self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }
}

#pragma mark - keyboard
- (void)onKeyboardFrameChange:(NSNotification *)notification {
    
    if(![self.inputTextView isFirstResponder] && ([self.navigationController isMovingFromParentViewController] || [self.navigationController isBeingDismissed]))
    {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.view convertRect:keyboardEndFrame fromView:nil];
    CGFloat heightFromBottom = CGRectGetMaxY(self.view.frame) - CGRectGetMinY(keyboardEndFrameConverted);
    heightFromBottom = MAX(0.0f, heightFromBottom);
    
    [self animateBottomBarsWithDuration:animationDuration options:animationCurveOption height:heightFromBottom];
}

- (void)animateBottomBarsWithDuration:(double)duration options:(UIViewAnimationOptions)options height:(CGFloat)heightFromBottom {
    
    BOOL isResigningKeyboard = heightFromBottom < 1;
    @weakify(self);
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^
     {
         @strongify(self);
         //输入框位置
         self.inputViewBottomCons.constant = heightFromBottom;
         
         [self.view setNeedsUpdateConstraints];
         [self.view layoutIfNeeded];
         
         self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
         // 激活键盘，一定上拉到最底，显示最后一条消息
         if (!isResigningKeyboard)
         {
             CGFloat maxScrollY = self.tableView.contentSize.height - self.tableView.bounds.size.height;
             if (maxScrollY > 0)
             {
                 self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, maxScrollY);
             }
         }
     }
                     completion:NULL];
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)notification {
    
    [self onKeyboardFrameChange:notification];
}

#pragma mark - private loginView
- (void)_setupLoginView{
    if (![LOVEModel shareModel].conversation) {
        BaseViewModel * loginViewModel = nil;
#ifdef WIFE_VERSION
        loginViewModel = [[LOVEViewModel alloc] initWithVCName:NSStringFromClass(LOVELViewController.class) withInitType:GULoadVCFromXib];
        [self.viewModel presentViewModel:loginViewModel animated:NO completion:nil];
#else
        
        loginViewModel = [[LoginViewModel alloc] initWithVCName:NSStringFromClass(LoginViewController.class) withInitType:GULoadVCFromXib];
        [self.viewModel presentViewModel:loginViewModel animated:YES completion:nil];
#endif
    }
}
#pragma mark - animation
- (void)resetAnimationView{
    if (self.animationView) {
        [self.animationView play];
        return;
    }

    NSString * animationName = @"background_full";
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
#pragma mark - private send
- (void)sendPressed{
    [self.viewModel.sendMessageCommand execute:nil];
}

@end
