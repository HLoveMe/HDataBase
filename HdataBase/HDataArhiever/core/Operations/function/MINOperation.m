//
//  MINOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "MINOperation.h"

@implementation MINOperation
+(instancetype)Operation:(id)msg{
    MINOperation *max = [MINOperation new];
    max.level = 3;
    if([msg isKindOfClass:[PropertyCondition class]]){
        max.content = [NSString stringWithFormat:@"MIN(%@)",[(PropertyCondition *)msg tableProName]];
    }else{
        max.content = [NSString stringWithFormat:@"MIN(%@)",msg];
    }
    return max;
}
@end
