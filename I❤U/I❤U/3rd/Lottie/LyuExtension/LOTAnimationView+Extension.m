//
//  LOTAnimationView+Extension.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/4/3.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "BaseHeaders.h"
#import "LOTAnimationView+Extension.h"
#import "LOTComposition.h"
#import "LOTAnimationCache.h"

static NSString * const jsonSubfix = @".json";
static NSString * const kAnimFileExt = @".json";

@implementation LOTAnimationView (Extension)

+ (LOTAnimationView *)animationNamed:(NSString *)animationName rootDir:(NSString *)rootDir subDir:(NSString *)subDir{
    return [self animationNamed:animationName rootDir:rootDir subDir:subDir imgsDict:nil];
}

+ (LOTAnimationView *)animationNamed:(NSString *)animationName rootDir:(NSString *)rootDir subDir:(NSString *)subDir imgsDict:(NSDictionary *)imgsDict{
    //nil
    if (!animationName || !rootDir) {
        return  [LOTAnimationView animationNamed:animationName];
    }
    //path
    NSString * resourcePath = rootDir;
    if (subDir) {
        resourcePath = [resourcePath stringByAppendingPathComponent:subDir];
    }
    if ([animationName containsString:jsonSubfix]) {
        resourcePath = [resourcePath stringByAppendingPathComponent:animationName];
    }else{
        resourcePath = [resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",animationName,jsonSubfix]];
    }
//    //cache
    LOTAnimationView * animationView = [LOTAnimationView alloc];
    LOTComposition * composition = [[LOTAnimationCache sharedCache] animationForKey:resourcePath];
    if (composition) {
        animationView = [animationView initWithModel:composition inBundle:[NSBundle mainBundle]];
        return  animationView;
    }
    NSError * jsonError = nil;
    NSData * jsonData = [[NSData alloc] initWithContentsOfFile:resourcePath];
    NSDictionary * jsonDict = nil;
    if (jsonData) {
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    }
    //local
    if (!jsonError && jsonDict) {
        LOTComposition * localComposition = [[LOTComposition alloc] initWithJSON:jsonDict withAssetBundle:[NSBundle mainBundle]];
        localComposition.rootDirectory = [resourcePath stringByDeletingLastPathComponent];
        [[LOTAnimationCache sharedCache] addAnimation:localComposition forKey:resourcePath];
        animationView = [animationView initWithModel:localComposition inBundle:[NSBundle mainBundle]];
        return animationView;
    }
    //error
    NSException * errorException = [NSException exceptionWithName:@"找不到动画资源" reason:[jsonError localizedDescription] userInfo:nil];
    @throw errorException;
}

@end
