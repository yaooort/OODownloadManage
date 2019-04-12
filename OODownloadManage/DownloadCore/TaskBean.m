//
//  TaskBean.m
//  OODownloadManage
//
//  Created by bunny on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "TaskBean.h"

@implementation TaskBean
- (instancetype)init{
    self = [super init]; //用于初始化父类
    if (self) {
        
    }
    return self;
}
+ (instancetype)shareInstace{
    return [[self alloc] init];
}

/**
 如果需要指定“唯一约束”字段, 在模型.m文件中实现该函数,这里指定 task_id 为“唯一约束”.
 */
+(NSArray *)bg_uniqueKeys{
    return @[@"task_id"];
}


@end
