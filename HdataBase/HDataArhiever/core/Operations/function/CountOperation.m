//
//  CountOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "CountOperation.h"
#import "PropertyCondition.h"
#import "DataBaseConnect.h"
@implementation CountOperation
+(instancetype)Operation:(id)msg{
    CountOperation *op = [CountOperation new];
    op.level = 3;
    if([msg isKindOfClass:[PropertyCondition class]]){
        op.content = [NSString stringWithFormat:@"COUNT(%@)",[(PropertyCondition *)msg tableProName]];
    }else{
        op.content = [NSString stringWithFormat:@"COUNT(%@)",msg];
    }
    
    return op;
}
@end
