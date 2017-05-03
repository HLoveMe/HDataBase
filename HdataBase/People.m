//
//  People.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "People.h"

@implementation People
+(instancetype)people:(NSString*)name age:(int)age address:(NSString *)address sl:(double)sl{
    People *p = [People new];
    p.name = name;
    p.age = age;
    p.address = address;
    p.alalry = sl;
    return p;
}
@end
