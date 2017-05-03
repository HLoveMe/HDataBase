//
//  CompareOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "CompareOperation.h"

@implementation CompareOperation
+(instancetype)Operation:(NSString *)name compare:(FMDBCompare)compare value:(double)va{
    CompareOperation *op = [CompareOperation new];
    op.level = 4;
    op.isAnd = YES;
    NSString *com;
    switch (compare) {
        case A:
            com = @">";
            break;
        case B:
            com = @"<";
            break;
        case C:
            com = @"=";
            break;
        case D:
            com = @">=";
            break;
        case E:
            com = @"<=";
            break;
        default:
            break;
    }
    op.content = [NSString stringWithFormat:@" %@ %@ %f ",name,com,va];
    return op;
}
+(instancetype)Operation:(NSString *)name compare:(FMDBCompare)compare value:(double)va and:(BOOL)AndOR{
    CompareOperation *op = [CompareOperation Operation:name compare:compare value:va];
    op.isAnd = AndOR;
    return op;
}
@end
