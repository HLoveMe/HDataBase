//
//  student.m
//  HdataBase
//
//  Created by space on 16/2/27.
//  Copyright © 2016年 Space. All rights reserved.
//

#import "student.h"
#import <objc/runtime.h>
@implementation student
-(instancetype)initWithName:(NSString*)name age:(int)age gender:(NSString *)gender address:(NSString *)address source:(int)source weight:(double)weight{
    if (self= [super init]) {
        self.name = name;
        self.age= age;
        self.gender = gender;
        self.address= address;
        self.source = source;
        self.weight = weight;
    }
    return self;
}
@end
