//
//  DownloadEngine.m
//  OODownloadManage
//
//  Created by bunny on 2019/4/15.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "DownloadEngine.h"

@implementation DownloadEngine
singleM(DownloadEngine)
- (instancetype)init
{
    self = [super init]; //用于初始化父类
    if (self) {
    }
    return self;
}

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


@end
