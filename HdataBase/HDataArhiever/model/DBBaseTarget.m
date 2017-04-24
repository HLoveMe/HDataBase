//
//  DBBaseTarget.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "DBBaseTarget.h"
@interface DBBaseTarget()
@end
@implementation DBBaseTarget
-(NSArray *)dbFileds{
    //return nil @[] 都是容许所有属性
    return @[];
}
/**
 -(SEL)test{
    if(_test){return _test;}
    SEL asel  = NSSelectorFromString(@"selBoxs:");
    if([self respondsToSelector:asel]){
        NSValue *value =[self performSelector:asel withObject:@"test"];
        SEL sel;
        [value getValue:&sel];
        return sel;
    }
    return nil;
 }
 */
@end



