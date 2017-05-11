//
//  AVGOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "AVGOperation.h"

@implementation AVGOperation
+(instancetype)Operation:(id)msg{
    AVGOperation *max = [AVGOperation new];
    max.level = 3;
    if([msg isKindOfClass:[PropertyCondition class]]){
        max.content = [NSString stringWithFormat:@"AVG(%@)",[(PropertyCondition *)msg tableProName]];
    }else{
        max.content =[NSString stringWithFormat:@"AVG(%@)",msg];
    }
    return max;
}
@end
