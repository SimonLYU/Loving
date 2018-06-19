//
//  FunctionOneViewModel.m
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "FunctionOneViewModel.h"

@interface FunctionOneViewModel()
@property (nonatomic, strong) NSMutableArray *textArray;
@end

@implementation FunctionOneViewModel

- (void)initialize{
    [super initialize];
    [self setupTextArray];
}

- (RACCommand *)talkTitleCommand{
    if (!_talkTitleCommand) {
        _talkTitleCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @weakify(self)
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self getRandomText];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _talkTitleCommand;
}

#pragma mark - private
- (void)setupTextArray{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tryToSay" ofType:nil];
    NSString *str = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray  *array = [str componentsSeparatedByString:@"\n"];
    NSMutableArray * textArray = [NSMutableArray array];
    for (NSString * text in array){
        if (text && ![text isEqualToString:@""] && ![text isEqualToString:@"\n"]){
            [textArray addObject:text];
        }
    }
    self.textArray = textArray;
}

- (void)getRandomText{
    if (self.textArray && self.textArray.count > 0){
        self.talkTitle = (NSString *)[self.textArray objectAtIndex:arc4random_uniform((uint32_t)self.textArray.count)];
        [Log info:NSStringFromClass(self.class) message:@"getRandomText : %@",self.talkTitle];
    }
}

@end
