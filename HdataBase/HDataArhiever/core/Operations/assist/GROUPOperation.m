//
//  GROUPOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "GROUPOperation.h"
@interface GROUPOperation()
@property(nonatomic,copy)NSString *name;
@end
@implementation GROUPOperation
+(instancetype)Operation:(NSString *)name{
    GROUPOperation *opera = [[GROUPOperation alloc]init];
    opera.name = name;
    opera.level = 8;
    opera.content = [NSString stringWithFormat:@" GROUP BY %@ ",name];
    return opera;
}
@end
