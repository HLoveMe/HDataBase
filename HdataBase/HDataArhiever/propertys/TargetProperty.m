//
//  TargetProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "TargetProperty.h"

@implementation TargetProperty
-(NSString *)getReadValue:(long(^)(id<DBArhieverProtocol> obj))block value:(id)value{
    if (block && value){
        long ID = block(value);
        NSString *clas = NSStringFromClass([value class]);
        return [@[@(ID),clas] componentsJoinedByString:@"---"];
    }
    return [Property nullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set{
    NSString *sqlvalue = [set stringForColumn:self.name];
    
    if(![self dataBaseIsValue:sqlvalue])
        return nil;
    
    NSArray *va = [sqlvalue componentsSeparatedByString:@"---"];
    Class clazz = NSClassFromString([va lastObject]);
    NSAssert(clazz != nil, @"数据库值 无法获取class");
    NSString *oneself = [va firstObject];
    if (block) {
        return block(oneself,clazz);
    }
    return nil;
}
@end
