//
//  OODownload.h
//  OODownloadManage
//
//  Created by oort on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskBean.h"
#import "DownloadEngine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OODownloadDelegate <NSObject>
@required
//必须实现的方法
- (void)updateAllTask:(NSMutableArray<TaskBean *> *) tasks;
// 可选实现的方法
@optional
- (void)readBook;
- (void)writeCode;
@end

@interface OODownload : NSObject

singleH(OODownload)

@property(nonatomic, strong) NSMutableDictionary<NSString *, DownloadEngine *>  * arrayTaskQueue;

@property (nonatomic, weak, nullable) id <OODownloadDelegate> delegate;

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
