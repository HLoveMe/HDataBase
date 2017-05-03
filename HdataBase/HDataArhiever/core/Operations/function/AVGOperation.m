//
//  AVGOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "AVGOperation.h"

@implementation AVGOperation
+(instancetype)Operation:(NSString*)name{
    AVGOperation *max = [AVGOperation new];
    max.level = 3;
    max.content = [NSString stringWithFormat:@" AVG(%@) ",name];
    return max;
}
@end
