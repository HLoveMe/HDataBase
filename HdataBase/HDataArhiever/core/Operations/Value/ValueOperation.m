//
//  ValueOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "ValueOperation.h"
@interface ValueOperation()
@end
@implementation ValueOperation
+(instancetype)Operation:(NSArray *)proNames{
    ValueOperation *op = [ValueOperation new];
    op.level  = 1;
    op.pros = [proNames mutableCopy];
    return op;
}

@end
