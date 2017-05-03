//
//  LimitOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "LimitOperation.h"

@interface LimitOperation()
@property(nonatomic,assign)NSRange range;
@end
@implementation LimitOperation
+(instancetype)Operation:(NSRange)range{
    LimitOperation*op = [LimitOperation new];
    op.range = range;
    op.level = 10;
    op.content = [NSString stringWithFormat:@" limit %ld offset %ld",range.length,range.location];
    return op;
}

@end
