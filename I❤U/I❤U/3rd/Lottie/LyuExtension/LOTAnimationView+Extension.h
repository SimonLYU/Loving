//
//  LOTAnimationView+Extension.h
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/4/3.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "LOTAnimationView.h"

@interface LOTAnimationView (Extension)

+ (LOTAnimationView *)animationNamed:(NSString *)animationName rootDir:(NSString *)rootDir subDir:(NSString *)subDir;

+ (LOTAnimationView *)animationNamed:(NSString *)animationName rootDir:(NSString *)rootDir subDir:(NSString *)subDir imgsDict:(NSDictionary *)imgsDict;

@end
