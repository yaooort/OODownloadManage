//
//  ViewController.m
//  OODownloadManage
//
//  Created by bunny on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "ViewController.h"
#import "OODownload.h"
#import "TaskBean.h"
#define tab_name @"taskoort"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *as = @[].mutableCopy;
    TaskBean *bean;
    for (int i=0; i<10; i++) {
        bean = [TaskBean new];
        bean.bg_tableName = tab_name;
//        bean.tableName = tab_name;
        bean.file_Name = @"你是谁.zip";
        [bean setModel_id:i];
        bean.url = @"https://github.com/oldj/SwitchHosts/releases/download/v3.3.12/SwitchHosts-macOS-x64_v3.3.12.5349.zip";
        bean.model = @{@"abc":@"qwe",@"as":[NSNumber numberWithInt:i]};
        [as addObject:bean];
    }
//    TaskBean *beanq = [TaskBean new];
//    beanq.bg_tableName = tab_name;
//    //        bean.tableName = tab_name;
//    beanq.file_Name = @"你是谁";
//    [beanq setModel_id:200];
//    beanq.url = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg";
////    beanq.model = @{@"abc":@"qwe",@"as":[NSNumber numberWithInt:200]};
//    [beanq bg_saveOrUpdate];
//    NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"model_id"),bg_sqlValue([NSNumber numberWithInt:200])];
//    NSArray* arr = [TaskBean bg_find:tab_name where:where];
    //创建一个任务队列
    [[OODownload shareOODownload] createTask:tab_name :as];
    [[OODownload shareOODownload] startAll:tab_name];
//    //删除一个任务队列，如果正在下载则停止并删除
//    [[OODownload shareOODownload] deleteTaskData:@"yigerenwu"];
//    //停止一个任务队列
//    [[OODownload shareOODownload] stopAll:@"yigerenwu"];
//
//    //停止队列中的某个任务
//    [[OODownload shareOODownload] stop:@"yigerenwu" model_id:123];
//    //向队列中添加一个任务
//    [[OODownload shareOODownload] add:@"yigerenwu" model:bean];
//    //删除队列中的某个任务，如果正在下载则停止并删除
//    [[OODownload shareOODownload] remove:@"yigerenwu" model_id:123];
//    //开启队列中一个任务
//    [[OODownload shareOODownload] start:@"yigerenwu" model_id:123];
//    //开启队列
//    [[OODownload shareOODownload] startAll:@"yigerenwu"];
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
