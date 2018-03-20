//
//  Log.m
//  I❤U
//
//  Created by 吕旭明 on 2018/3/7.
//  Copyright © 2018年 吕旭明. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <UIKit/UIKit.h>

#import "Log.h"

#pragma mark - LogConfig

@implementation LogConfig

- (id)init {
    if (self = [super init]) {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _dir = [cachesDirectory stringByAppendingPathComponent:@"Logs"];
        _policy = LogFilePolicyPerLaunch;
        _outputLevel = LogLevelVerbose;
        _fileLevel = LogLevelInfo;
        _fileKeepDays = 7;
    }
    return self;
}

@end

#pragma mark - static

static LogConfig *logConfig = nil;
static NSString *logFilePath = nil;
static NSFileHandle *logFileHandle = nil;
static NSString *lastLogFilePath = nil;

static bool isLoggable(LogLevel level) {
    return level >= logConfig.outputLevel;
}

static NSString *logLevelToString(LogLevel level) {
    NSString *str;
    switch (level) {
        case LogLevelVerbose: {
            str = @"Verbose";
            break;
        }
        case LogLevelDebug: {
            str = @"Debug";
            break;
        }
        case LogLevelInfo: {
            str = @"Info";
            break;
        }
        case LogLevelWarn: {
            str = @"Warn";
            break;
        }
        case LogLevelError: {
            str = @"Error";
            break;
        }
        default: {
            str = @"Unknown";
            break;
        }
    }
    return str;
}

static NSString *getFileLogText(NSString *text) {
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    });
    
    
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    NSString *logText = [NSString stringWithFormat:@"%@ %@\r\n", date, text];
    return logText;
}

static NSString *formatLogStr(NSString *tag, LogLevel level, NSString *format, va_list args) {
    NSString *input = [[NSString alloc] initWithFormat:format arguments:args];
    NSString *thread;
    if ([[NSThread currentThread] isMainThread]) {
        thread = @"Main";
    } else {
        thread = [NSString stringWithFormat:@"%p", [NSThread currentThread]];
    }
    
    NSString *logString = [NSString stringWithFormat:@"[%@][%@][%@] %@", thread, tag, logLevelToString(level), input];
    return logString;
}

static void deleteOldLogFiles() {
    NSError *error = nil;
    NSArray *logFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logConfig.dir error:&error];
    if (logFiles) {
//        NSLog(@"logfiles:");
        NSDate *now = [NSDate date];
        NSTimeInterval time = [now timeIntervalSince1970];
        time -= logConfig.fileKeepDays * 24 * 60 * 60;
        
        NSDate *latestFileDate = nil;
        NSUInteger count = [logFiles count];
        for (NSString *s in logFiles) {
            
            NSString *path = [NSString stringWithFormat:@"%@/%@", logConfig.dir, s];
            NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
            NSDate *fileDate = [attr fileCreationDate];
            
//            NSDate *keepDate = [NSDate dateWithTimeIntervalSince1970:time];
//            NSLog(@"%@: %@, now %@, last %@", s, fileDate, now, keepDate);
            
            //保留最近三个文件，就算已经超出日期也不删除
            if ([fileDate timeIntervalSince1970] < time && count > 3) {
                if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
                    NSLog(@"removed old log file: %@", path);
                    count--;
                } else {
                    NSLog(@"remove old log file error:%@", error);
                }
            } else {    //顺便计算一下上次的log文件路径
                if (lastLogFilePath) {
                    if ([fileDate timeIntervalSince1970] > [latestFileDate timeIntervalSince1970]) {
                        latestFileDate = fileDate;
                        lastLogFilePath = path;
                    }
                } else {
                    lastLogFilePath = path;
                    latestFileDate = fileDate;
                }
            }
        }
    } else {
        NSLog(@"deleteOldLogFiles failed: %@", error);
    }
}
static void createLogFile() {
    NSString *dir = logConfig.dir;
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dir
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            NSLog(@"Error occurred while creating log dir(%@): %@", dir, error);
        }
    }
    
    if (!error) {
        
        deleteOldLogFiles();
        
        NSDate* date = [NSDate date];
        
        //log at most one file a day
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        if (logConfig.policy == LogFilePolicyPerDay)
            [formatter setDateFormat:@"yyyy-MM-dd"];
        else
            [formatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        
        logFilePath = [NSString stringWithFormat:@"%@/%@.log", dir, [formatter stringFromDate:date]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:logFilePath
                                                    contents:nil
                                                  attributes:nil];
        }
        
        logFileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [logFileHandle seekToEndOfFile];  //need to move to the end when first open
        
        // 强制输出log头部
        NSString *logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, @"---------------------- Log Begin ----------------------", NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, [NSString stringWithFormat:@"device name: %@", @"nil"], NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, [NSString stringWithFormat:@"device systemName: %@", [[UIDevice currentDevice] systemName]], NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, [NSString stringWithFormat:@"device systemVersion: %@", [[UIDevice currentDevice] systemVersion]], NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, [NSString stringWithFormat:@"device model: %@", [[UIDevice currentDevice] model]], NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, [NSString stringWithFormat:@"app version: %@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]], NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, [NSString stringWithFormat:@"app build: %@", [infoDictionary objectForKey:@"CFBundleVersion"]], NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        logText = getFileLogText(formatLogStr(@"Log", LogLevelInfo, [NSString stringWithFormat:@"log file: %@", logFilePath], NULL));
        NSLog(@"%@", logText);
        [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
    }
}



static void logToFile(NSString *text) {
    static dispatch_once_t onceToken;
    static dispatch_queue_t logQueue;

    dispatch_once(&onceToken, ^{
        logQueue = dispatch_queue_create("logQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(logQueue, ^{
            createLogFile();
        });
    });
    
    dispatch_async(logQueue, ^{
        
        NSString *logText = getFileLogText(text);
        
        @try {
            [logFileHandle seekToEndOfFile]; 
            [logFileHandle writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
        } @catch(NSException *e) {
            NSLog(@"Error: cannot write log file with exception %@", e);
            logFileHandle = nil;
            createLogFile();
        }
        
    });
}



static void logInternal(NSString *tag, LogLevel level, NSString *format, va_list args)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (logConfig == nil) {
            logConfig = [[LogConfig alloc] init];
        }
    });
    
    if (isLoggable(level)) {
        NSString *logString = formatLogStr(tag, level, format, args);
        NSLog(@"%@", logString);
        
        if (level >= logConfig.fileLevel && logConfig.policy != LogFilePolicyNoLogFile) {
            logToFile(logString);
        }
    }
}



#pragma mark - Log

@implementation Log


+ (void)config:(LogConfig *)cfg {
    if (cfg) {
        logConfig = cfg;
    } else {
        logConfig = [[LogConfig alloc] init];
    }
}

+ (NSString *)logFileDir {
    return logConfig.dir;
}

+ (NSString *)logUploadFileDir{
    return [NSString stringWithFormat:@"%@/lup", [Log logFileDir]];
}

+ (NSString *)logFilePath {
    return logFilePath;
}

+ (NSString *)lastLogFilePath {
    return lastLogFilePath;
}

+ (NSArray *)logFileListFrom:(NSDate *)fromDate to:(NSDate *)toDate force:(BOOL)force
{
    return [Log logFileListFrom:fromDate to:toDate force:force appMax:kMaxAppLogFileCount zegoMax:kMaxZegoLogFileCount crashMax:kMaxCrashFileCount];
}

static UInt32 const kMaxAppLogFileCount = 100;
+ (NSArray *)logFileListFrom:(NSDate *)fromDate to:(NSDate *)toDate force:(BOOL)force appMax:(UInt32)appMax zegoMax:(UInt32)zegoMax crashMax:(UInt32)crashMax
{
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    
    if (!fromDate && !toDate) {
        if (logFilePath) {
            [fileList addObject:logFilePath];
        }
    } else {
        if (!fromDate) {
            fromDate = [NSDate date];
        }
        if (!toDate) {
            toDate = [NSDate date];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *fromDateString = [dateFormatter stringFromDate:fromDate];
        fromDate = [dateFormatter dateFromString:fromDateString];
        
        NSString *toDateString = [dateFormatter stringFromDate:toDate];
        toDate = [dateFormatter dateFromString:toDateString];
        
        NSComparisonResult dateComparision = [fromDate compare:toDate];
        
        NSString *regex = @"";
        
        while (dateComparision != NSOrderedDescending) {
            fromDateString = [dateFormatter stringFromDate:fromDate];
            regex = [regex stringByAppendingFormat:@"%@ SELF LIKE '%@*.log' ", regex.length == 0 ? @"":@"||", fromDateString ];
            
            // fromDate 加1天
            NSTimeInterval aDay = 24*60*60;
            fromDate = [fromDate dateByAddingTimeInterval:aDay];
            dateComparision = [fromDate compare:toDate];
        }
        
        if (regex.length > 0) { // 没有符合条件的日期
            NSPredicate *predicate = [NSPredicate predicateWithFormat:regex ];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *allFileList = [fileManager subpathsAtPath:[Log logFileDir]];
            NSArray *filteredSubPathList = [allFileList filteredArrayUsingPredicate:predicate];
            UInt32 count =0;
            for (NSInteger i = filteredSubPathList.count-1; i >= 0; i --)
            {
                NSString *subPath = filteredSubPathList[i];
                NSString *fullPath = [NSString stringWithFormat:@"%@/%@", [Log logFileDir], subPath];
                [fileList addObject:fullPath];
                count++;
                if (appMax <= count)
                {
                    break;
                }
            }
        }
    }
    if (!force)
    {
        return fileList;
    }
    NSArray* zegoLogFiles = [Log getZegoLogFiles:zegoMax];
    [fileList addObjectsFromArray:zegoLogFiles];
    NSArray*  crashLogFiles = [Log getCrashFiles:crashMax];
    [fileList addObjectsFromArray:crashLogFiles];
    return fileList;
}

static UInt32 const kMaxZegoLogFileCount = 10;
static UInt32 const kLogFileToUploadMaxSize = (1024*1024*10);

+ (NSArray*)getZegoLogFiles:(UInt32)maxFileCount
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* rootPath = [cachesDirectory stringByAppendingPathComponent:@"ZegoLogs"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *paths = [fileMgr subpathsAtPath:rootPath];//取得文件列表
    NSArray *sortedPaths = [paths sortedArrayUsingComparator:^(NSString * firstPath, NSString* secondPath)
    {//
        NSString *firstUrl = [rootPath stringByAppendingPathComponent:firstPath];//获取前一个文件完整路径
        NSString *secondUrl = [rootPath stringByAppendingPathComponent:secondPath];//获取后一个文件完整路径
        NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstUrl error:nil];//获取前一个文件信息
        NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondUrl error:nil];//获取后一个文件信息
        id firstData = [firstFileInfo objectForKey:NSFileModificationDate];//获取前一个文件修改时间
        id secondData = [secondFileInfo objectForKey:NSFileModificationDate];//获取后一个文件修改时间
        //return [firstData compare:secondData];//升序
        return [secondData compare:firstData];//降序
    }];
    NSMutableArray* files = [NSMutableArray arrayWithCapacity:maxFileCount];
    int count=0;
    for (NSString* filePath in sortedPaths)
    {
        NSString *curFileUrl = [rootPath stringByAppendingPathComponent:filePath];//获取前一个文件完整路径
        NSDictionary *curFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:curFileUrl error:nil];//获取前一个文件信息
        NSInteger fileSize = [[curFileInfo objectForKey:NSFileSize] integerValue];
        if (kLogFileToUploadMaxSize < fileSize)
        {
            continue;
        }
        [files addObject:curFileUrl];
        count++;
        if (maxFileCount <= count)
        {
            break;
        }
    }
    return files;
}

static UInt32 const kMaxCrashFileCount = 100;

+ (NSArray*)getCrashFiles:(UInt32)maxFileCount
{
    NSString* cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* crashReportDir = [cachesDir stringByAppendingPathComponent:@"CrashReport"];
    
    NSString *regex = @" SELF LIKE '*.crash' ";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:regex ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *allFileList = [fileManager subpathsAtPath:crashReportDir];
    NSArray *filteredSubPathList = [allFileList filteredArrayUsingPredicate:predicate];
    NSArray *sortedPaths = [filteredSubPathList sortedArrayUsingComparator:^(NSString * firstPath, NSString* secondPath)
    {
        NSString *firstUrl = [crashReportDir stringByAppendingPathComponent:firstPath];//获取前一个文件完整路径
        NSString *secondUrl = [crashReportDir stringByAppendingPathComponent:secondPath];//获取后一个文件完整路径
        NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstUrl error:nil];//获取前一个文件信息
        NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondUrl error:nil];//获取后一个文件信息
        id firstData = [firstFileInfo objectForKey:NSFileModificationDate];//获取前一个文件修改时间
        id secondData = [secondFileInfo objectForKey:NSFileModificationDate];//获取后一个文件修改时间
        //return [firstData compare:secondData];//升序
        return [secondData compare:firstData];//降序
    }];
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    int count=0;
    for (NSInteger i = 0; i < sortedPaths.count; i ++)
    {
        NSString *subPath = sortedPaths[i];
        NSString *fullPath = [crashReportDir stringByAppendingPathComponent:subPath];
        [fileList addObject:fullPath];
        count++;
        if (maxFileCount <= count)
        {
            break;
        }
    }
    return fileList;
}


+ (void)log:(NSString *)tag level:(LogLevel)level message:(NSString *)format, ...NS_FORMAT_FUNCTION(3, 4) {
    va_list args;
    va_start(args, format);
    logInternal(tag, level, format, args);
    va_end(args);
}

+ (void)log:(NSString *)tag level:(LogLevel)level format:(NSString *)format args:(va_list)args
{
    logInternal(tag, level, format, args);
}

+ (void)verbose:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3) {
    va_list args;
    va_start(args, format);
    logInternal(tag, LogLevelVerbose, format, args);
    va_end(args);
}

+ (void)debug:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3) {
    va_list args;
    va_start(args, format);
    logInternal(tag, LogLevelDebug, format, args);
    va_end(args);
}

+ (void)info:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3) {
    va_list args;
    va_start(args, format);
    logInternal(tag, LogLevelInfo, format, args);
    va_end(args);
}

+ (void)warn:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3) {
    va_list args;
    va_start(args, format);
    logInternal(tag, LogLevelWarn, format, args);
    va_end(args);
}

+ (void)error:(NSString *)tag message:(NSString *)format, ...NS_FORMAT_FUNCTION(2, 3) {
    va_list args;
    va_start(args, format);
    logInternal(tag, LogLevelError, format, args);
    va_end(args);
}

@end
