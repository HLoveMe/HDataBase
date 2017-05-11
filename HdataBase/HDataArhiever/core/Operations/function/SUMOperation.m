//
//  SUMOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "SUMOperation.h"

@implementation SUMOperation
+(instancetype)Operation:(id)msg{
    SUMOperation *max = [SUMOperation new];
    max.level = 3;
    if([msg isKindOfClass:[PropertyCondition class]]){
        max.content = [NSString stringWithFormat:@"SUM(%@)",[(PropertyCondition *)msg tableProName]];
    }else{
        max.content = [NSString stringWithFormat:@"SUM(%@)",msg];
    }
    
    return max;
}
@end
