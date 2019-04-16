//
//  DownloadEngine.h
//  OODownloadManage
//
//  Created by bunny on 2019/4/15.
//  Copyright © 2019 Oort. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadEngine : NSOperationQueue

/** 下载任务队列名称，对应数据库的表名称 */
@property (nonatomic, strong) NSString *taskTable;


@end

NS_ASSUME_NONNULL_END
