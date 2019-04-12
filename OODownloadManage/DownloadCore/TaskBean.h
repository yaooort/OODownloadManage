//
//  TaskBean.h
//  OODownloadManage
//
//  Created by bunny on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGFMDB.h" //添加该头文件,本类就具有了存储功能.
NS_ASSUME_NONNULL_BEGIN

@interface TaskBean : NSObject
/**
 本库自带的自动增长主键.
 */
@property(nonatomic,strong)NSNumber*_Nullable bg_id;
//在当前队列中的ID，必须唯一
@property(nonatomic, assign)  NSInteger task_id;
//下载的文件url
@property(nonatomic, copy)    NSString *url;
//文件名称
@property(nonatomic, copy)    NSString *name;
//图片介绍展示
@property(nonatomic, copy)    NSString *image;
//当前下载的对象json
@property(nonatomic, copy)    NSDictionary *model;
//当前下载速度
@property(nonatomic, assign)  NSInteger speed;
//总文件大小
@property(nonatomic, assign)  NSInteger length;
//当前下载的大小
@property(nonatomic, assign)  NSInteger current;

+ (instancetype)shareInstace;

@end

NS_ASSUME_NONNULL_END
