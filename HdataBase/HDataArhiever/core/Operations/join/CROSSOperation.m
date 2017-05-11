//
//  CROSSOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/10.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "CROSSOperation.h"
#import "DataBaseConnect.h"
#import "PropertyCondition.h"
#import "PrepareStatus.h"
@interface CROSSOperation()
@end
@implementation CROSSOperation
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

-(NSString *)content:(Class)origin{
    return [self performSelector:@selector(content:Join:) withObject:origin withObject:@" CROSS JOIN "];
}
#pragma clang diagnostic pop
-(instancetype)initOperationJoin:(Class)class with:(id)condition{
    if(self=[super initOperationJoin:class with:condition]){
        return self;
    }
    return self;
}
-(instancetype)initOperationJoin:(Class)class self:(NSArray *)ProAs other:(NSArray *)ProBs compare:(NSArray *)compares con:(NSArray<NSNumber *> *)ands{
    if (self=[super initOperationJoin:class self:ProAs other:ProBs compare:compares con:ands]) {
        
    }
    return self;
}
@end
