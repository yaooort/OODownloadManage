//
//  OOOperation.m
//  OODownloadManage
//
//  Created by bunny on 2019/4/16.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "OOOperation.h"


#define k_executing @"isExecuting"
#define k_cancelled @"isCancelled"
#define k_finished @"isFinished"

@interface OOOperation ()
{
    BOOL _executing;
    BOOL _cancelled;
    BOOL _finished;
}
@property (nonatomic, assign) NSInteger model_id;

@property (nonatomic, strong) NSString *table_name;
/** 文件句柄对象 */
@property (nonatomic, strong) NSFileHandle *fileHandle;
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
/* AFURLSessionManager */
@property (nonatomic, strong) AFURLSessionManager *manager;

@end
@implementation OOOperation

- (id)init {
    if(self = [super init])
    {
    }
    return self;
}

-(TaskBean*) getTaskBean {
    /**
     按条件查询.
    */
    NSString* where = [NSString stringWithFormat:@"where %@ = %@",bg_sqlKey(@"model_id"),bg_sqlValue([NSNumber numberWithInteger:(self.model_id)])];
    NSArray* arr = [TaskBean bg_find:self.table_name where:where];
    NSArray * ts = [TaskBean bg_findAll:self.table_name];
    
    return arr.count>0 ? arr[0] : nil;
}


- (id)initWithTaskBean:(TaskBean*) bean {
    if(self = [super init])
    {
        self.bean = bean;
        self.table_name = bean.bg_tableName;
        self.model_id = bean.model_id;
    }
    return self;
}

//暂停任务
- (void)suspendTask {
    
    [self willChangeValueForKey:k_executing];
    _executing = NO;
    [self.downloadTask suspend];
    self.getTaskBean.status = YHFileDownloadSuspend;
    [self.getTaskBean bg_saveOrUpdate];
    [self didChangeValueForKey:k_executing];
    
}
//继续任务
- (void)resumeTask {
    
    [self willChangeValueForKey:k_executing];
    _executing = YES;
    [self.downloadTask resume];
    self.getTaskBean.status = YHFileDownloaddownload;
    [self.getTaskBean bg_saveOrUpdate];
    [self didChangeValueForKey:k_executing];
}

// 重写父类方法
- (void)start {
    self.getTaskBean.status = YHFileDownloadBegin;
    if (self.isCancelled) {
        [self willChangeValueForKey:k_finished];
        _finished = YES;
        [self didChangeValueForKey:k_finished];
    } else {
        [self willChangeValueForKey:k_executing];
        _executing = YES;
        [self.downloadTask resume];
        self.getTaskBean.status = YHFileDownloadBegin;
        [self didChangeValueForKey:k_executing];
    }
    [self.getTaskBean bg_saveOrUpdate];
}

// 取消
- (void)cancel {
    [self willChangeValueForKey:k_cancelled];
    [super cancel];
    [self.downloadTask cancel];
    self.downloadTask = nil;
    [self didChangeValueForKey:k_cancelled];
    [self completion];
}
// 结束
- (void)completion {
    [self willChangeValueForKey:k_executing];
    [self willChangeValueForKey:k_finished];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:k_executing];
    [self didChangeValueForKey:k_finished];
}
- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

//- (void)main {
//    @try {
//        @autoreleasepool {
//            //在这里定义自己的并发任务
//            NSLog(@"自定义并发操作NSOperation");
//            [NSThread sleepForTimeInterval:3]; // 模拟耗时操作
//            NSThread *thread = [NSThread currentThread];
//            NSLog(@"当前线程%@",thread);
//            //任务执行完成后要实现相应的KVO
//            [self willChangeValueForKey:@"isFinished"];
//            [self willChangeValueForKey:@"isExecuting"];
//            _executing = NO;
//            _finished = YES;
//            [self didChangeValueForKey:@"isExecuting"];
//            [self didChangeValueForKey:@"isFinished"];
//        }
//    }
//    @catch (NSException *exception) {
//
//    }
//}
/**
 * manager的懒加载
 */
- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}

/**
 * downloadTask的懒加载
 */
- (NSURLSessionDataTask *)downloadTask {
    if (!_downloadTask) {
        // 创建下载URL
        NSURL *url = [NSURL URLWithString:self.getTaskBean.url];
        
        // 2.创建request请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.getTaskBean.currentLength?self.getTaskBean.currentLength:0];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        __weak typeof(self) weakSelf = self;
        _downloadTask = [self.manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"%@",uploadProgress);
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"%@",downloadProgress);
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            // 清空长度
            //            weakSelf.currentLength = 0;
            //            weakSelf.fileLength = 0;
            self.getTaskBean.status = YHFileDownloadFailure;
            [self.getTaskBean bg_saveOrUpdate];
            // 关闭fileHandle
            [weakSelf.fileHandle closeFile];
            weakSelf.fileHandle = nil;
        }];
        
        [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
            NSLog(@"NSURLSessionResponseDisposition");
            
            // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            weakSelf.getTaskBean.fileLength = response.expectedContentLength + weakSelf.getTaskBean.currentLength;
            
            // 沙盒文件路径
            
            NSLog(@"File downloaded to: %@",weakSelf.getTaskBean.absolutePath);
            
            // 创建一个空的文件到沙盒中
            NSFileManager *manager = [NSFileManager defaultManager];
            
            if (![manager fileExistsAtPath:weakSelf.getTaskBean.absolutePath]) {
                // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
                [manager createFileAtPath:weakSelf.getTaskBean.absolutePath contents:nil attributes:nil];
            }
            
            // 创建文件句柄
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.getTaskBean.absolutePath];
            
            // 允许处理服务器的响应，才会继续接收服务器返回的数据
            return NSURLSessionResponseAllow;
        }];
        
        [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            NSLog(@"setDataTaskDidReceiveDataBlock");
            
            // 指定数据的写入位置 -- 文件内容的最后面
            [weakSelf.fileHandle seekToEndOfFile];
            
            // 向沙盒写入数据
            [weakSelf.fileHandle writeData:data];
            
            // 拼接文件总长度
            weakSelf.getTaskBean.currentLength += data.length;
            
            // 获取主线程，不然无法正确显示进度。
            NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                // 下载进度
                if (weakSelf.getTaskBean.fileLength != 0) {
                    NSLog(@"当前下载进度:%.2f%%",100.0 * weakSelf.getTaskBean.currentLength / weakSelf.getTaskBean.fileLength);
                }
                [weakSelf.getTaskBean bg_saveOrUpdate];
            }];
        }];
    }
    return _downloadTask;
}

/**
 * 获取已下载的文件大小
 */
- (NSInteger)fileLengthForPath:(NSString *)path {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

@end
