//
//  TaskBean.h
//  OODownloadManage
//
//  Created by bunny on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGFMDB.h" //添加该头文件,本类就具有了存储功能.
@class TaskBean;
    //开始
#define  YHFileDownloadBegin  1
    //下载中
#define  YHFileDownloaddownload  2
    //暂停
#define   YHFileDownloadSuspend  3
    //完成
#define  YHFileDownloadFinshed  4
    //等待
#define  YHFileDownloadWaiting  5
    //失败
#define  YHFileDownloadFailure  6

NS_ASSUME_NONNULL_BEGIN

@interface TaskBean : NSObject
/**
 本库自带的自动增长主键.
 */
//@property(nonatomic,strong)   NSNumber*_Nullable bg_id;
//在当前队列中的ID，必须唯一
@property(nonatomic, assign)  NSInteger model_id;
//下载的文件url
@property(nonatomic, copy)    NSString *url;
//沙盒文件的绝对d路径
@property(nonatomic, copy)    NSString *absolutePath;
//文件名称带后缀
@property(nonatomic, copy)    NSString *file_Name;
//当前下载的对象json
@property(nonatomic, copy)    NSDictionary *model;
//当前下载的百分比
@property(nonatomic, assign)  float percentage;
//当前下载速度
@property(nonatomic, assign)  float speed;
//总文件大小
@property(nonatomic, assign)  long fileLength;
//当前下载的大小
@property(nonatomic, assign)  long currentLength;
//当前下载状态
@property(nonatomic, assign)  NSInteger status;
//数据库自带的更新时间暂时不用需要转换麻烦
@property(nonatomic, assign)  NSInteger updateTimeStamp;
//取更新时间时候的数据大小
@property(nonatomic, assign)  long updateTimeFile;


@end

NS_ASSUME_NONNULL_END
