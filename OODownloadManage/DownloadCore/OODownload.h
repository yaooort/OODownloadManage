//
//  OODownload.h
//  OODownloadManage
//
//  Created by oort on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskBean.h"

NS_ASSUME_NONNULL_BEGIN

@interface OODownload : NSObject

singleH(OODownload)

-(void)createTask:(NSString *)name :(NSArray *)tasks;

-(void)deleteTaskData:(NSString *)name;

-(void)stopAll:(NSString *)name;

-(void)stop:(NSString *)name model_id:(NSInteger) model;

-(void)add:(NSString *)name model:(TaskBean *) model;

-(void)remove:(NSString *)name model_id:(NSInteger) model;

-(void)start:(NSString *)name model_id:(NSInteger) model;

-(void)startAll:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
