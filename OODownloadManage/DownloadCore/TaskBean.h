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
//文件状态
typedef NS_ENUM(NSInteger,YHFileDownloadStatus) {
    //开始
    YHFileDownloadBegin = 1,
    //下载中
    YHFileDownloaddownload,
    //暂停
    YHFileDownloadSuspend,
    //完成
    YHFileDownloadFinshed,
    //等待
    YHFileDownloadWaiting,
    //失败
    YHFileDownloadFailure,
};
NS_ASSUME_NONNULL_BEGIN

@interface TaskBean : NSObject
/**
 本库自带的自动增长主键.
 */
@property(nonatomic,strong)   NSNumber*_Nullable bg_id;
//在当前队列中的ID，必须唯一
@property(nonatomic, assign)  NSInteger model_id;
//下载的文件url
@property(nonatomic, copy)    NSString *url;
//沙盒文件的绝对d路径
@property(nonatomic, copy)    NSString *absolutePath;
//文件名称
@property(nonatomic, copy)    NSString *file_Name;
//数据库表名称
//@property(nonatomic, copy)    NSString *tableName;
//图片介绍展示
@property(nonatomic, copy)    NSString *image;
//当前下载的对象json
@property(nonatomic, copy)    NSDictionary *model;
//当前下载速度
@property(nonatomic, assign)  NSInteger speed;
//总文件大小
@property(nonatomic, assign)  NSInteger fileLength;
//当前下载的大小
@property(nonatomic, assign)  NSInteger currentLength;
//当前下载状态
@property(nonatomic, assign)  YHFileDownloadStatus status;

+ (instancetype)shareInstace;

@end

NS_ASSUME_NONNULL_END
