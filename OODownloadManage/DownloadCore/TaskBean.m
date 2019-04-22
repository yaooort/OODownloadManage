//
//  TaskBean.m
//  OODownloadManage
//
//  Created by bunny on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "TaskBean.h"
#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define filePath @"/DataVideo"

@implementation TaskBean

/**
 如果需要指定“唯一约束”字段, 在模型.m文件中实现该函数,这里指定 task_id 为“唯一约束”.
 */
+(NSArray *)bg_uniqueKeys{
    return @[@"model_id"];
}

/**
 设置不需要存储的属性, 在模型.m文件中实现该函数.
 */
+(NSArray *)bg_ignoreKeys{
    return @[@"block"];
}


-(NSInteger)updateTimeStamp{
    if(!_updateTimeStamp){
        _updateTimeStamp = [[NSDate date] timeIntervalSince1970];
    }
    return _updateTimeStamp;
}

-(float)speed{
    if(!_speed){
        _speed = 0;
    }
    return _speed;
}

-(void)addBlock:(TaskBlock) block{
    
}


-(long)updateTimeFile{
    if(!_updateTimeFile){
        _updateTimeFile = 0;
    }
    return _updateTimeFile;
}


-(long)fileLength{
    if(!_fileLength){
        _fileLength = 0;
    }
    return _fileLength;
}



-(long)currentLength{
    if(!_currentLength){
        _currentLength = [self fileLengthForPath:[self absolutePath]];
    }
    return _currentLength;
}

-(NSInteger)status{
    if(!_status){
        _status = YHFileDownloadBegin;
    }
    return _status;
}


- (NSString *)absolutePath {
    NSString *fileName = [NSString stringWithFormat:@"%ld-%@",(long)self.model_id,self.file_Name];
    return [[self createFileDir] stringByAppendingPathComponent:fileName];
}



- (NSString*)createFileDir {
    //沙盒路径 kDocumentPath
    //创建目录
    NSString *createPath = [NSString stringWithFormat:@"%@%@", kDocumentPath,filePath];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return createPath;
}

/**
 * 获取已下载的文件大小
 */
- (long)fileLengthForPath:(NSString *)path {
    long fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [[NSNumber numberWithLongLong:[fileDict fileSize]] longValue];
        }
    }
    return fileLength;
}

@end
