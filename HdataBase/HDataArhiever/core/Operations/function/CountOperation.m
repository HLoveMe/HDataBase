//
//  CountOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "CountOperation.h"

@implementation CountOperation
+(instancetype)Operation:(NSString*)name{
    CountOperation *op = [CountOperation new];
    op.level = 3;
    op.content = [NSString stringWithFormat:@"count(%@)",name];
    return op;
}
@end
