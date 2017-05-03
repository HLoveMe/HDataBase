//
//  LIKEOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "LIKEOperation.h"
@interface LIKEOperation()
@end
@implementation LIKEOperation
+(instancetype)Operation:(NSString *)proName like:(NSString *)content{
    LIKEOperation *opera = [[LIKEOperation alloc]init];
    opera.content = [NSString stringWithFormat:@" %@ LIKE '%@'",proName,content];
    opera.level = 5;
    opera.isAnd = YES;
    return opera;
}
+(instancetype)Operation:(NSString *)proName like:(NSString *)content and:(BOOL)isAnd{
    LIKEOperation *opera = [LIKEOperation Operation:proName like:content];
    opera.isAnd = isAnd;
    return opera;
}
@end
