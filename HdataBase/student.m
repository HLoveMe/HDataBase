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
-(NSString *)description{
    NSMutableString *one= [NSMutableString string];
    unsigned int num;
    objc_property_t *pros =  class_copyPropertyList(self.class, &num);
    for (int i=0; i<num; i++) {
        NSString *name = [NSString stringWithUTF8String:property_getName(pros[i])];
        id value = [self valueForKey:name];
        if(!([value integerValue]==0||[value stringValue].length==0)){
            [one appendFormat:@"  %@: %@",name,value];
        }
    }
    return one;
}
@end
