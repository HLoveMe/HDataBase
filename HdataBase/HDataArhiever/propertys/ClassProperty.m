//
//  ClassProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "ClassProperty.h"
#import "ClassManager.h"
@implementation ClassProperty
-(NSString *)getReadValue:(long (^)(id<DBArhieverProtocol>))block value:(id)value{
    return NSStringFromClass([ClassManager valueClass:value]);
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set sqlV:(NSString *)sqlV class:(Class)clazz{
    if(!sqlV)return nil;
    return NSClassFromString(sqlV);
}
@end
