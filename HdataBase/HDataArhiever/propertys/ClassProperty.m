//
//  ClassProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "ClassProperty.h"

@implementation ClassProperty
-(NSString *)getReadValue:(long (^)(id<DBArhieverProtocol>))block value:(id)value{
    return NSStringFromClass(value);
}
-(id)valueWithSet:(id<DBArhieverProtocol> (^)(NSString *, __unsafe_unretained Class))block set:(FMResultSet *)set{
    NSString *sqlvalue = [set stringForColumn:self.name];
    return NSClassFromString(sqlvalue);
}
@end
