//
//  MINOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "MINOperation.h"

@implementation MINOperation
+(instancetype)Operation:(NSString*)name{
    MINOperation *max = [MINOperation new];
    max.level = 3;
    max.content = [NSString stringWithFormat:@" MAX(%@) ",name];
    return max;
}
@end
