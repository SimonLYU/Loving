//
//  HttpUtil.m
//  ヾ(･ε･｀*)
//
//  Created by 吕旭明 on 2018/3/21.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import "HttpUtil.h"
#import "Log.h"
@interface HttpUtil()<NSURLSessionDelegate>

@end

@implementation HttpUtil

+ (HttpUtil *)sharedInstance{
    static HttpUtil * defaultSharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultSharedInstance = [[HttpUtil alloc] init];
        defaultSharedInstance.sharedSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:defaultSharedInstance delegateQueue:[[NSOperationQueue alloc] init]];
    });
    return defaultSharedInstance;
}

- (void)addCommonParas:(NSMutableDictionary *)paras{
    //todo...拼接common参数
}

- (void)postHttpRequestForPath:(NSString *)path
                         paras:(NSMutableDictionary *)paras
                    completion:(void(^)(NSData *result, NSURLResponse *response, NSError *error))completion{
    /*************** 处理参数 ***************/
    //拼接common参数
    if (!paras) {
        paras = [NSMutableDictionary dictionary];
    }
    [self addCommonParas:paras];
    //序列化requestBody
    NSError * jsonError = nil;
    NSData * requestBodyData = [NSJSONSerialization dataWithJSONObject:paras options:0 error:&jsonError];
    if (!requestBodyData) {
        if (!jsonError) jsonError = nil;//todo...自定义error内容
        if (completion) {
            completion(nil,nil,jsonError);
        }
        return;
    }
    /*************** 处理request ***************/
    NSURL * requestUrl = [NSURL URLWithString:path];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestBodyData;
    /*************** 处理dataTask任务 ***************/
    NSURLSessionDataTask * dataTask = [[HttpUtil sharedInstance].sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //Log
            NSString* stringRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [Log info:NSStringFromClass(self.class) message:@"postHttpRequestForPath stringRet=%@",stringRet];
            //回调
            if (completion) {
                completion(data,response,error);
            }
        }];
    }];
    [dataTask resume];
}

- (void)getHttpRequestForPath:(NSString *)path
                        paras:(NSMutableDictionary *)paras
                   completion:(void(^)(NSData *result, NSURLResponse *response, NSError *error))completion{
    /*************** 处理参数 ***************/
    //拼接common参数
    if (!paras) {
        paras = [NSMutableDictionary dictionary];
    }
    [self addCommonParas:paras];
    for (int i = 0; i < paras.allKeys.count; ++i) {
        NSString * param = nil;
        if (i == 0) {
            param = [NSString stringWithFormat:@"?%@=%@",paras.allKeys[i],paras.allValues[i]];
        }else
        {
            param = [NSString stringWithFormat:@"&%@=%@",paras.allKeys[i],paras.allValues[i]];
        }
        path = [path stringByAppendingString:param];
    }
    /*************** 处理request ***************/
    NSURL * requestUrl = [NSURL URLWithString:path];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"GET";
    /*************** 处理dataTask任务 ***************/
    NSURLSessionDataTask * dataTask = [[HttpUtil sharedInstance].sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //Log
            NSString* stringRet = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [Log info:NSStringFromClass(self.class) message:@"postHttpRequestForPath stringRet=%@",stringRet];
            //回调
            if (completion) {
                completion(data,response,error);
            }
        }];
    }];
    [dataTask resume];
}

@end
