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
@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end
@implementation OOOperation

//-(TaskBean*) getTaskBean {
//    /**
//     按条件查询.
//    */
//    NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"model_id"),bg_sqlValue([NSNumber numberWithInteger:(self.model_id)])];
//    NSArray* arr = [TaskBean bg_find:self.table_name where:where];
//
//    return arr.count>0 ? arr[0] : nil;
//}


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
    self.bean.status = YHFileDownloadSuspend;
    [self.bean bg_saveOrUpdate];
    [self didChangeValueForKey:k_executing];
    
}
//继续任务
- (void)resumeTask {
    
    [self willChangeValueForKey:k_executing];
    _executing = YES;
    [self.downloadTask resume];
    self.bean.status = YHFileDownloaddownload;
    [self.bean bg_saveOrUpdate];
    [self didChangeValueForKey:k_executing];
}

// 重写父类方法
- (void)start {
    self.bean.status = YHFileDownloadBegin;
    if (self.isCancelled) {
        [self willChangeValueForKey:k_finished];
        _finished = YES;
        [self didChangeValueForKey:k_finished];
    } else {
        [self willChangeValueForKey:k_executing];
        _executing = YES;
        [self.downloadTask resume];
        self.bean.status = YHFileDownloadBegin;
        [self didChangeValueForKey:k_executing];
    }
    [self.bean bg_saveOrUpdate];
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
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 1. 创建会话管理者
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}

/**
 * downloadTask的懒加载
 */
- (NSURLSessionDataTask *)downloadTask {
    if (!_downloadTask) {
        if(self.bean.status==YHFileDownloadSuspend||self.bean.status==YHFileDownloadFinshed||self.bean.status==YHFileDownloadFailure){
            [self over];
        }
        // 创建下载URL
        NSURL *url = [NSURL URLWithString:self.bean.url];
        // 2.创建request请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // 设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", self.bean.currentLength?self.bean.currentLength:0];
        [self.manager.requestSerializer setValue:range forHTTPHeaderField:@"Range"];
        [request setValue:range forHTTPHeaderField:@"Range"];
        __weak typeof(self) weakSelf = self;
        _downloadTask = [self.manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
//            NSLog(@"%f",downloadProgress.fractionCompleted);
            if(downloadProgress.fractionCompleted==1){
                //任务执行完成后要实现相应的KVO
                [weakSelf downloadOver:YES];
            }else{
//                NSLog(@"当前下载进度:%.2f%%",downloadProgress.fractionCompleted*100);
//                NSLog(@"当前下载进度:%.2f%%",100.0 * weakSelf.bean.currentLength / weakSelf.bean.fileLength);
            }
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [weakSelf downloadOver:NO];
        }];
        
        [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
//            NSLog(@"NSURLSessionResponseDisposition");NSHTTPURLResponse
//            if(response.)
            NSHTTPURLResponse *responseHttp = (NSHTTPURLResponse*)response;
            // 获得下载文件的总长度：请求下载的文件长度 + 当前已经下载的文件长度
            if(responseHttp.statusCode!=206){
                //返回都失败了
                [weakSelf downloadOver:NO];
                return NSURLSessionResponseCancel;
//                NSLog(@"%ld",responseHttp.statusCode);
            }
            weakSelf.bean.fileLength = response.expectedContentLength + weakSelf.bean.currentLength;
            [weakSelf.bean bg_saveOrUpdate];
            // 创建文件句柄
            weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.bean.absolutePath];
            // 允许处理服务器的响应，才会继续接收服务器返回的数据
            return NSURLSessionResponseAllow;
        }];
        
        [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
            // 指定数据的写入位置 -- 文件内容的最后面
            [weakSelf.fileHandle seekToEndOfFile];
            
            // 向沙盒写入数据
            [weakSelf.fileHandle writeData:data];
            
            // 拼接文件总长度
            weakSelf.bean.currentLength += data.length;
            weakSelf.bean.percentage = 100.0 * weakSelf.bean.currentLength / weakSelf.bean.fileLength;
            [weakSelf.bean bg_saveOrUpdate];
            
            NSInteger time = [[NSDate date] timeIntervalSince1970];
            NSInteger timeS = weakSelf.bean.updateTimeStamp;
            NSInteger ca = time-timeS;
            if(ca >= 1){
                //计算下载速度
                weakSelf.bean.speed = (weakSelf.bean.currentLength - weakSelf.bean.updateTimeFile)/ca;
                //更新本条记录文件大小及时间
                weakSelf.bean.updateTimeStamp = time;
                weakSelf.bean.updateTimeFile = weakSelf.bean.currentLength;
                [weakSelf.bean bg_saveOrUpdate];
                NSLog(@"下载速度%f",weakSelf.bean.speed);
            }
        }];
    }
    return _downloadTask;
}


-(void)downloadOver:(BOOL) isSuccess{
    if(self.fileHandle){
        // 关闭fileHandle
        [self.fileHandle closeFile];
        self.fileHandle = nil;
    }
    if(isSuccess){
        self.bean.status = YHFileDownloadFinshed;
    }else{
        self.bean.fileLength = 0;
        self.bean.status = YHFileDownloadFailure;
    }
    [self.bean bg_saveOrUpdate];
    [self over];
}

-(void)over{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    _finished = YES;
    //    _downloadTask = nil;
    //    _manager = nil;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}
@end
