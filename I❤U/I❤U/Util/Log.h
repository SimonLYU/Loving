//
//  Log.h
//  I❤U
//
//  Created by 吕旭明 on 2018/3/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    LogLevelVerbose,
    LogLevelDebug,
    LogLevelInfo,
    LogLevelWarn,
    LogLevelError
} LogLevel;

typedef enum : NSUInteger {
    LogFilePolicyNoLogFile,
    LogFilePolicyPerDay,
    LogFilePolicyPerLaunch,
} LogFilePolicy;

@interface LogConfig : NSObject

@property (nonatomic, copy) NSString *dir;                       // log文件目录，不指定的话默认为Cache/Logs
@property (nonatomic) LogFilePolicy policy;                // log文件策略
@property (nonatomic) LogLevel outputLevel;                // 输出级别，大于等于此级别的log才会输出
@property (nonatomic) LogLevel fileLevel;                  // 输出到文件的级别，大于等于此级别的log才会写入文件
@property (nonatomic) NSUInteger fileKeepDays;               // Log文件保留天数，默认7天

@end

@interface Log : NSObject

// 配置，需要在程序初始化调用，传nil的话使用默认配置
+ (void)config:(LogConfig *)cfg;

// 当前log文件夹
+ (NSString *)logFileDir;

// 上传日志压缩包文件夹
+ (NSString *)logUploadFileDir;

// 当前log文件路径
+ (NSString *)logFilePath;

+ (NSString *)lastLogFilePath;

+ (NSArray *)logFileListFrom:(NSDate *)fromDate to:(NSDate *)toDate force:(BOOL)force;

+ (NSArray *)logFileListFrom:(NSDate *)fromDate to:(NSDate *)toDate force:(BOOL)force appMax:(UInt32)appMax zegoMax:(UInt32)zegoMax crashMax:(UInt32)crashMax;

+ (void)log:(NSString *)tag level:(LogLevel)level message:(NSString *)format, ...NS_FORMAT_FUNCTION(3, 4);

+ (void)log:(NSString *)tag level:(LogLevel)level format:(NSString *)format args:(va_list)args;

+ (void)verbose:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3);

+ (void)debug:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3);

+ (void)info:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3);

+ (void)warn:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3);

+ (void)error:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3);

@end
