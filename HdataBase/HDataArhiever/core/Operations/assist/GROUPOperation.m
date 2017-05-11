//
//  GROUPOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "GROUPOperation.h"
@interface GROUPOperation()
@end
@implementation GROUPOperation
+(instancetype)Operation:(id)msg{
    GROUPOperation *opera = [[GROUPOperation alloc]init];
    opera.level = 8;
    opera.content = [NSString stringWithFormat:@" GROUP BY %@ ",msg];
    return opera;
}
@end
