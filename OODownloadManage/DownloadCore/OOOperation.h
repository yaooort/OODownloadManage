//
//  OOOperation.h
//  OODownloadManage
//
//  Created by bunny on 2019/4/16.
//  Copyright © 2019 Oort. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TaskBean.h"
#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface OOOperation : NSOperation

@property (nonatomic, strong) TaskBean *bean;
//创建任务
- (instancetype)initWithTaskBean:(TaskBean *)bean;
//暂停任务
- (void)suspendTask;
//继续任务
- (void)resumeTask;

@end

NS_ASSUME_NONNULL_END
