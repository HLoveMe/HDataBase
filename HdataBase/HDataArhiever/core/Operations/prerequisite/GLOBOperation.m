//
//  GLOBOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "GLOBOperation.h"

@implementation GLOBOperation

+(instancetype)Operation:(id)msg compera:(NSString *)com and:(BOOL)isAnd{
    GLOBOperation *op = [GLOBOperation new];
    op.level = 6;
    op.isAnd = isAnd;
    op.content = [NSString stringWithFormat:@" %@ GLOB '%@'",msg,com];
    return op;
}
@end
