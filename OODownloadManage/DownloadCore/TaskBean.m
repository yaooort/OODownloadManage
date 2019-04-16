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

- (instancetype)init{
    self = [super init]; //用于初始化父类
    if (self) {
        
    }
    return self;
}
+ (instancetype)shareInstace{
    return [[self alloc] init];
}

/**
 如果需要指定“唯一约束”字段, 在模型.m文件中实现该函数,这里指定 task_id 为“唯一约束”.
 */
+(NSArray *)bg_uniqueKeys{
    return @[@"model_id"];
}

//-(void)tableName:(NSString *) tableName{
//    self.bg_tableName = tableName;
//    self.tableName = tableName;
//}

//-(NSString *)bg_tableName{
//    return self.tableName;
//}

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
@end
