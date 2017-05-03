//
//  SUMOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "SUMOperation.h"

@implementation SUMOperation
+(instancetype)Operation:(NSString *)name{
    SUMOperation *max = [SUMOperation new];
    max.level = 3;
    max.content = [NSString stringWithFormat:@" SUM(%@) ",name];
    return max;
}
@end
