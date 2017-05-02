//
//  DictionaryProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "DictionaryProperty.h"
#import "GeneralProperty.h"
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
        [res addObject:@"Dictionary"];
        return [res componentsJoinedByString:[Property separatedString]];
    }
    return [Property dictionarynullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set sqlV:(NSString *)sqlV class:(Class)cla{
    
    if(!sqlV)return nil;
    if(![Property dataBaseIsValue:sqlV])return nil;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    NSArray *va = [sqlV componentsSeparatedByString:[Property separatedString]];
    
    for (int i=0; i<va.count-1; i+=3) {
        NSString *key  = va[i]; //key
        NSString* oneself = va[i+1];//value
        Class clazz = NSClassFromString(va[i+2]);//class
        NSAssert(clazz != nil, @"数据库值 无法获取class");
        if([clazz isBaseTarget]){
            id value = block(oneself,clazz);
            [result setValue:value forKey:key];
        }else{
            id value = [GeneralProperty valueWithstr:oneself class:clazz];
            [result setValue:value forKey:key];
        }
    }
    return result;
}

@end
