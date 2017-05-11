//
//  DISTINOTOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "DISTINOTOperation.h"

@implementation DISTINOTOperation
+(instancetype)Operation:(NSArray *)pros{
    DISTINOTOperation *op = [DISTINOTOperation new];
    op.level  = 2;
    NSMutableArray *temp = [NSMutableArray array];
    [pros enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [temp addObject:[NSString stringWithFormat:@"DISTINCT %@",obj]];
    }];
    op.pros = temp;
    return op;
}
@end
