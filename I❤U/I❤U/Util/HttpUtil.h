//
//  HttpUtil.h
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/21.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpUtil : NSObject

@property (nonatomic, strong) NSURLSession *sharedSession;

+ (HttpUtil *)sharedInstance;

/**
 * 发送POST请求
 */
- (void)postHttpRequestForPath:(NSString *)path
                         paras:(NSMutableDictionary *)paras
                    completion:(void(^)(NSData *result, NSURLResponse *response, NSError *error))completion;
/**
 * 发送GET请求
 */
- (void)getHttpRequestForPath:(NSString *)path
                        paras:(NSMutableDictionary *)paras
                   completion:(void(^)(NSData *result, NSURLResponse *response, NSError *error))completion;

@end
