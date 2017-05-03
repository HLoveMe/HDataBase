//
//  GLOBOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "GLOBOperation.h"

@implementation GLOBOperation
+(instancetype)Operation:(NSString *)name compera:(NSString *)com{
    GLOBOperation *op = [GLOBOperation new];
    op.level = 6;
    op.isAnd = YES;
    op.content = [NSString stringWithFormat:@" %@ GLOB '%@'",name,com];
    return op;
}
+(instancetype)Operation:(NSString *)name compera:(NSString *)com and:(BOOL)isAnd{
    GLOBOperation *op = [GLOBOperation Operation:name compera:com];
    op.isAnd = isAnd;
    return op;

}
@end
