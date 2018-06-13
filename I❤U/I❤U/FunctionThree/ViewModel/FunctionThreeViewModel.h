//
//  FunctionThreeViewModel.h
//  ヾ(･ε･｀*)
//
//  Created by Simon on 2018/6/11.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseViewModel.h"

typedef NS_ENUM(NSUInteger, GameState) {
    kGameStateEnded,
    kGameStateStarting,
};

@interface FunctionThreeViewModel : BaseViewModel

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) NSMutableArray *planeList;
@property (nonatomic, assign) CGPoint targetPoint;

@property (nonatomic, assign) GameState gameState;

@property (nonatomic, strong) NSString *myPlanesMapString;
@property (nonatomic, strong) NSArray<NSArray *> *myPlanesMap;
@property (nonatomic, strong) NSArray *myDestroyPoints;
@property (nonatomic, assign) NSInteger myDestroyCount;

@property (nonatomic, strong) NSString *targetPlanesMapString;
@property (nonatomic, strong) NSArray<NSArray *> *targetPlanesMap;
@property (nonatomic, strong) NSArray *targetDestroyPoints;
@property (nonatomic, assign) NSInteger targetDestroyCount;

@property (nonatomic, assign) BOOL iAmReady;
@property (nonatomic, assign) BOOL targetIsReady;

@property (nonatomic, strong) RACCommand *readyOrRemoveCommand;
@property (nonatomic, strong) RACCommand *endOrAddCommand;
@property (nonatomic, strong) RACCommand *editOrFinishCommand;
@property (nonatomic, strong) RACCommand *fireCommand;

@end
