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
    TaskBean *bean = [TaskBean shareInstace];
    NSMutableArray *as = @[].mutableCopy;
    [as addObject:bean];
    [[OODownload shareOODownload] createTask:@"yigerenwu" :as];
    
    [[OODownload shareOODownload] deleteTaskData:@"yigerenwu"];
    
    [[OODownload shareOODownload] stopAll:@"yigerenwu"];
    
    
    [[OODownload shareOODownload] stop:@"yigerenwu" model_id:123];
    
    [[OODownload shareOODownload] add:@"yigerenwu" model:bean];
    
    [[OODownload shareOODownload] remove:@"yigerenwu" model_id:123];
    
    [[OODownload shareOODownload] start:@"yigerenwu" model_id:123];
    
    [[OODownload shareOODownload] startAll:@"yigerenwu"];
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
