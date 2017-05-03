//
//  ORDEROperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "ORDEROperation.h"
@interface ORDEROperation()

@end
@implementation ORDEROperation
+(instancetype)Operation:(NSString *)name{
    ORDEROperation *operation = [[ORDEROperation alloc]init];
    operation.level = 9;
    BOOL up = [name hasPrefix:@"-"];
    if(!up){
        operation.content = [NSString stringWithFormat:@" ORDER BY %@ ASC",name];
    }else{
        name = [name substringFromIndex:1];
        operation.content = [NSString stringWithFormat:@" ORDER BY %@ DESC",name];
    }
    return operation;
}

@end
