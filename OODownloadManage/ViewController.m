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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *as = @[].mutableCopy;
    TaskBean *bean;
    for (int i=0; i<100; i++) {
        bean = [TaskBean shareInstace];
        bean.name = @"你是谁";
        bean.model = @{@"abc":@"qwe",@"as":[NSNumber numberWithInt:i]};
        [as addObject:bean];
    }
    
    //创建一个任务队列
    [[OODownload shareOODownload] createTask:@"yigerenwu" :as];
    //删除一个任务队列，如果正在下载则停止并删除
    [[OODownload shareOODownload] deleteTaskData:@"yigerenwu"];
    //停止一个任务队列
    [[OODownload shareOODownload] stopAll:@"yigerenwu"];
    
    //停止队列中的某个任务
    [[OODownload shareOODownload] stop:@"yigerenwu" model_id:123];
    //向队列中添加一个任务
    [[OODownload shareOODownload] add:@"yigerenwu" model:bean];
    //删除队列中的某个任务，如果正在下载则停止并删除
    [[OODownload shareOODownload] remove:@"yigerenwu" model_id:123];
    //开启队列中一个任务
    [[OODownload shareOODownload] start:@"yigerenwu" model_id:123];
    //开启队列
    [[OODownload shareOODownload] startAll:@"yigerenwu"];
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
