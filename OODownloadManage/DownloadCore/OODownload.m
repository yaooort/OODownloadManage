//
//  OODownload.m
//  OODownloadManage
//
//  Created by oort on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "OODownload.h"
#import "OOOperation.h"

#import <Foundation/Foundation.h>


@implementation OODownload
singleM(OODownload)
- (instancetype)init
{
    self = [super init]; //用于初始化父类
    if (self) {
        [self init_download];
        [self init_db];
    }
    return self;
}

#pragma mark--初始化下载
-(void)init_download{
    
}


# pragma mark--初始化数据库
-(void)init_db{
    /**
     想测试更多功能,打开注释掉的代码即可.
     */
//    bg_setDebug(YES);//打开调试模式,打印输出调试信息.
    /**
     如果频繁操作数据库时,建议进行此设置(即在操作过程不关闭数据库).
     */
    bg_setDisableCloseDB(YES);
    
    /**
     手动关闭数据库(如果设置了bg_setDisableCloseDB(YES)，则在切换bg_setSqliteName前，需要手动关闭数据库一下).
     */
    //bg_closeDB();
    
    /**
     自定义数据库名称，否则默认为BGFMDB
     */
    bg_setSqliteName(@"OortDB");
    
    //删除自定义数据库.
    //bg_deleteSqlite(@"Tencent");
}

#pragma mark -- 懒加载
-(NSMutableDictionary<NSString *, DownloadEngine *> *)arrayTaskQueue{
    if(!_arrayTaskQueue){
        _arrayTaskQueue = [NSMutableDictionary new];
    }
    return _arrayTaskQueue;
}

#pragma mark -- 获取一个队列根据任务名称
-(DownloadEngine *)getEngineWithTabName:(NSString *) tabName{
    return [self.arrayTaskQueue objectForKey:tabName];
}

-(void)createTask:(NSString *)name :(NSArray *)tasks
{
//    [TaskBean bg_registerChangeForTableName:name identify:@"change" block:^(bg_changeState result) {
//        [self.delegate updateAllTask:[self getTaskAll :name]];
////        switch (result) {
////            case bg_insert:
////                NSLog(@"有数据插入");
////                break;
////            case bg_update:
////                NSLog(@"有数据更新");
////                break;
////            case bg_delete:
////                NSLog(@"有数据删删除");
////                break;
////            case bg_drop:
////                NSLog(@"有表删除");
////                break;
////            default:
////                break;
////        }
//    }];
    for (int i=0; i<tasks.count; i++) {
        TaskBean *bean = tasks[i];
        bean.status = YHFileDownloadWaiting;
        bean.bg_tableName = name;
    }
    [TaskBean bg_saveOrUpdateArray:tasks];
    
    // 创建下载队列
    DownloadEngine *engine = [[DownloadEngine alloc] init];
    engine.maxConcurrentOperationCount = 3;
    engine.taskTable = name;
    // 将单个执行单元放到队列中
    for (int i=0; i<tasks.count; i++) {
        OOOperation * oo = [[OOOperation alloc] initWithTaskBean:tasks[i]];
        [engine addOperation:oo];
    }
    [self.arrayTaskQueue setObject:engine forKey:name];
}


-(NSMutableArray<TaskBean *> *)getTaskAll:(NSString *)name
{
    return [TaskBean bg_findAll:name];
}

-(void)deleteTaskData:(NSString *)name
{
    [self stopAll:name];
    [TaskBean bg_drop:name];
}

-(void)stopAll:(NSString *)name
{
    DownloadEngine *engine = [self.arrayTaskQueue objectForKey:name];
    [engine setSuspended:YES];// 暂停
}

-(void)stop:(NSString *)name model_id:(NSInteger) model
{
    DownloadEngine *engine = [self.arrayTaskQueue objectForKey:name];
    NSArray * operations = engine.operations;
    for (int i=0; i<operations.count; i++) {
        OOOperation * oo = operations[i];
        TaskBean *bean = oo.bean;
        if(bean.model_id == model){
            [oo suspendTask];
        }
    }
}

-(void)add:(NSString *)name model:(TaskBean *) model
{
    model.bg_tableName = name;
    [model bg_saveOrUpdate];
    
    DownloadEngine *engine = [self.arrayTaskQueue objectForKey:name];
    OOOperation * oo = [[OOOperation alloc] initWithTaskBean:model];
    [engine addOperation:oo];
}

-(void)remove:(NSString *)name model_id:(NSInteger) model{
    [self stop:name model_id:model];
    NSNumber * task_id = [NSNumber numberWithInteger:model];
    NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"task_id"),bg_sqlValue(task_id)];
    [TaskBean bg_delete:name where:where];
    
    DownloadEngine *engine = [self.arrayTaskQueue objectForKey:name];
    NSArray * operations = engine.operations;
    for (int i=0; i<operations.count; i++) {
        OOOperation * oo = operations[i];
        TaskBean *bean = oo.bean;
        if(bean.model_id == model){
            [oo suspendTask];
        }
    }
}

-(void)start:(NSString *)name model_id:(NSInteger) model{
    DownloadEngine *engine = [self.arrayTaskQueue objectForKey:name];
    NSArray * operations = engine.operations;
    for (int i=0; i<operations.count; i++) {
        OOOperation * oo = operations[i];
        TaskBean *bean = oo.bean;
        if(bean.model_id == model){
            [oo resumeTask];
        }
    }
}

-(void)startAll:(NSString *)name
{
    DownloadEngine *engine = [self.arrayTaskQueue objectForKey:name];
    [engine setSuspended:NO];
}

//-(void)demo:(NSString*)name taskArr:(NSArray *) tasks{
//    /**
//     直接存储对象
//     */
//    for (int i=0; i<tasks.count; i++) {
//        TaskBean *bean = [tasks objectAtIndex:i];
//        bean.bg_tableName = [self tabName:name];
//        [bean bg_save];
//        //        [bean bg_saveAsync:^(BOOL isSuccess) {
//        //            //异步存储结果
//        //        }]
//        /**
//         覆盖掉原来TaskBean类的所有数据,只存储当前对象的数据.
//         */
//        //        [bean bg_cover];
//        /**
//         同步存储或更新.
//         当"唯一约束"或"主键"存在时，此接口会更新旧数据,没有则存储新数据.
//         提示：“唯一约束”优先级高于"主键".
//         */
//        [bean bg_saveOrUpdate];
//    }
//
//    /**
//     存储标识名为name的数组.
//     */
//    [tasks bg_saveArrayWithName:[self tabName:name]];
//    /**
//     同步 存储或更新 数组元素.
//     当"唯一约束"或"主键"存在时，此接口会更新旧数据,没有则存储新数据.
//     提示：“唯一约束”优先级高于"主键".
//     */
//    [TaskBean bg_saveOrUpdateArray:tasks];
//    /**
//     取出数组
//     */
//    NSArray* testResult = [NSArray bg_arrayWithName:[self tabName:name]];
//    for (int i=0; i<testResult.count; i++) {
//        TaskBean *bean = [testResult objectAtIndex:i];
//        NSLog(@"%@",bean.model);
//    }
//    /**
//     同步查询所有数据.
//     */
//    NSArray* finfAlls = [TaskBean bg_findAll:[self tabName:name]];
//
//    /**
//     按条件查询.
//     */
//    NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"斯巴达")];
//    NSArray* arr = [TaskBean bg_find:[self tabName:name] where:where];
//
//    /**
//     直接写SQL语句操作.
//     */
//    NSArray* arr_sql = bg_executeSql(@"select * from yy", [self tabName:name], [TaskBean class]);//查询时,后面两个参数必须要传入.
//
//    /**
//     根据范围查询.
//     */
//    NSArray* arr_d = [TaskBean bg_find:[self tabName:name] range:NSMakeRange(3,50) orderBy:nil desc:NO];
//
//    /**
//     单个对象更新.
//     支持keyPath.
//     */
//    //    NSString* where = [NSString stringWithFormat:@"where %@ or %@=%@",bg_keyPathValues(@[@"user.student.human.body",bg_equal,@"小芳"]),bg_sqlKey(@"age"),bg_sqlValue(@(31))];
//    //    [p bg_updateWhere:where];
//
//    /**
//     sql语句批量更新.
//     */
//    //    NSString* where = [NSString stringWithFormat:@"set %@=%@ where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"马化腾"),bg_sqlKey(@"name"),bg_sqlValue(@"天朝")];
//    //    [People bg_update:bg_tablename where:where];
//
//    /**
//     直接写SQL语句操作
//     */
//    //    bg_executeSql(@"update yy set BG_name='标哥'", nil, nil);//更新或删除等操作时,后两个参数不必传入.
//
//    /**
//     按条件删除.
//     */
//    //    NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(@"斯巴达")];
//    //    [People bg_delete:bg_tablename where:where];
//
//    /**
//     清除表的所有数据.
//     */
//    //    [People bg_clear:bg_tablename];
//
//    /**
//     删除数据库表.
//     */
//    //    [People bg_drop:bg_tablename];
//
//    [TaskBean bg_registerChangeForTableName:[self tabName:name] identify:@"change" block:^(bg_changeState result) {
//        switch (result) {
//            case bg_insert:
//                NSLog(@"有数据插入");
//                break;
//            case bg_update:
//                NSLog(@"有数据更新");
//                break;
//            case bg_delete:
//                NSLog(@"有数据删删除");
//                break;
//            case bg_drop:
//                NSLog(@"有表删除");
//                break;
//            default:
//                break;
//        }
//    }];
//    //    [TaskBean bg_removeChangeForTableName:bg_tablename identify:@"change"];
//}
@end

