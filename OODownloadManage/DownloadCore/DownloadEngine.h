//
//  DownloadEngine.h
//  OODownloadManage
//
//  Created by bunny on 2019/4/15.
//  Copyright © 2019 Oort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadEngine : NSObject
singleH(DownloadEngine)

/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
/* AFURLSessionManager */
@property (nonatomic, strong) AFURLSessionManager *manager;
@end

NS_ASSUME_NONNULL_END
