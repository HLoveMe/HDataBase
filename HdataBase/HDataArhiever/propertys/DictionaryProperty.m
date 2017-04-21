//
//  DictionaryProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "DictionaryProperty.h"

@implementation DictionaryProperty
-(NSString *)getReadValue:(long(^)(id<DBArhieverProtocol> obj))block value:(id)value{
    if (block&&value&&[value isKindOfClass:[NSDictionary class]]){
        NSDictionary *dic = (NSDictionary*)value;
        NSMutableArray *res = [NSMutableArray array];
        __block int count = 0;
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSAssert([self isCanSave:obj], @"数组 字典不能嵌套");
            NSString *clas = NSStringFromClass(self.valuesClazzs[count]);
            ValueType type = [self.vTypes[count] integerValue];
            
            [res addObject:key];
            if (type == isBaseTarget){
                [res addObject:@(block(obj))];
            }else{
                [res addObject:[obj description]];
            }
            [res addObject:clas];
            count++;
        }];
        return [res componentsJoinedByString:@"---"];
    }
    return [Property dictionarynullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol> (^)(NSString *, __unsafe_unretained Class))block set:(FMResultSet *)set{
    
    NSString *sqlvalue = [set stringForColumn:self.name];
    if(![self dataBaseIsValue:sqlvalue])
        return nil;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    NSArray *va = [sqlvalue componentsSeparatedByString:@"---"];
    
    for (int i=0; i<va.count; i+=3) {
        NSString *key  = va[i];
        NSString* oneself = va[i+1];
        Class clazz = NSClassFromString(va[i+2]);
        NSAssert(clazz != nil, @"数据库值 无法获取class");
        if([clazz isBaseTarget]){
            id value = block(oneself,clazz);
            [result setValue:value forKey:key];
        }else{
            id value = [self value:oneself class:clazz];
            [result setValue:value forKey:key];
        }
    }
    return result;
}

@end
