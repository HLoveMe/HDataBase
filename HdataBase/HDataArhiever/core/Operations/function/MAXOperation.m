//
//  MAXOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "MAXOperation.h"

@implementation MAXOperation
+(instancetype)Operation:(id)msg{
    MAXOperation *max = [MAXOperation new];
    max.level = 3;
    if([msg isKindOfClass:[PropertyCondition class]]){
        max.content = [NSString stringWithFormat:@"MAX(%@)",[(PropertyCondition *)msg tableProName]];
    }else{
        max.content = [NSString stringWithFormat:@"MAX(%@)",msg];
    }
    return max;
}
@end
