//
//  OODownload.m
//  OODownloadManage
//
//  Created by oort on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "OODownload.h"
#import <YYCache/YYCache.h>
@implementation OODownload

singleM(OODownload)

-(void)createTask:(NSString *)name :(NSArray *)tasks
{
    
}

-(void)deleteTaskData:(NSString *)name
{
    
}

-(void)stopAll:(NSString *)name
{
    
}

-(void)stop:(NSString *)name model_id:(NSInteger) model
{
    
}

-(void)add:(NSString *)name model:(TaskBean *) model
{
    
}

-(void)remove:(NSString *)name model_id:(NSInteger) model
{
    
}

-(void)start:(NSString *)name model_id:(NSInteger) model
{
    
}

-(void)startAll:(NSString *)name
{
    
}


-(void)saveModel:(TaskBean *) task
{
    YYCache *_dataCache =[[YYCache alloc] initWithName:@"ArticleCache"];
    _dataCache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning=YES;

    [_dataCache setObject:task forKey:@"cacheModelKey"];
}

-(TaskBean *)getModel:(NSString*) name{
    YYCache *dataCache =[[YYCache alloc] initWithName:@"ArticleCache"];
    dataCache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning=YES;
    TaskBean  *cacheModel = [dataCache objectForKey: @"cacheModelKey"];
    return cacheModel;
}

@end

