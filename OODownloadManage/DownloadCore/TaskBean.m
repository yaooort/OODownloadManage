//
//  TaskBean.m
//  OODownloadManage
//
//  Created by bunny on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "TaskBean.h"

@implementation TaskBean
+ (instancetype)shareInstace{
    return [[self alloc] init];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.task_id = [aDecoder decodeIntegerForKey:@"task_id"];
    self.url = [aDecoder decodeObjectForKey:@"url"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.image = [aDecoder decodeObjectForKey:@"image"];
    self.model = [aDecoder decodeObjectForKey:@"model"];
    self.speed = [aDecoder decodeIntegerForKey:@"speed"];
    self.length = [aDecoder decodeIntegerForKey:@"length"];
    self.current = [aDecoder decodeIntegerForKey:@"current"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.task_id forKey:@"task_id"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.model forKey:@"model"];
    [aCoder encodeInteger:self.speed forKey:@"speed"];
    [aCoder encodeInteger:self.length forKey:@"length"];
    [aCoder encodeInteger:self.current forKey:@"current"];
}
@end
