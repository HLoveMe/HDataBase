//
//  MAXOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "MAXOperation.h"

@implementation MAXOperation
+(instancetype)Operation:(NSString*)name{
    MAXOperation *max = [MAXOperation new];
    max.level = 3;
    max.content = [NSString stringWithFormat:@" MAX(%@) ",name];
    return max;
}
@end
