//
//  BaseModelUtil.m
//  WanShang
//
//  Created by 朱子豪 on 2017/8/10.
//  Copyright © 2017年 ZZH. All rights reserved.
//

#import "BaseModelUtil.h"
#import "DBBaseTargetProtocol.h"
@implementation BaseModelUtil
//得到唯一标示字段
+(NSString *)uniqueness:(id)objOrClass{
    SEL asel = NSSelectorFromString(@"uniqueness");
    NSString *name = @"oneself";
    id<DBArhieverProtocol> obj;
    if([objOrClass conformsToProtocol:@protocol(DBArhieverProtocol)]){
        obj = objOrClass;
    }else{
        obj=[[(Class)objOrClass alloc]init];
    }
    if([obj respondsToSelector:asel]){
        NSString *_name = [obj uniqueness];
        if(_name)
            name = _name;
    }
    return name;
}
@end
