//
//  ArrayProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "ArrayProperty.h"

@implementation ArrayProperty

-(NSString *)getReadValue:(long(^)(id<DBArhieverProtocol> obj))block value:(id)value{
    if (block&&value&&[value isKindOfClass:[NSArray class]]){
        NSArray *arr = (NSArray*)value;
        NSMutableArray *res = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSAssert([self isCanSave:obj], @"数组 字典不能嵌套");
            NSString *clas = NSStringFromClass(self.valuesClazzs[idx]);
            ValueType type = [self.vTypes[idx] integerValue];
            if (type == isBaseTarget){
                [res addObject:@(block(obj))];
            }else{
                [res addObject:[obj description]];
            }
            [res addObject:clas];
        }];
        return [res componentsJoinedByString:@"---"];
    }else{
        return [Property arraynullValue];
    }
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set class:(Class)clazz{
    if(block){return @[];}
    NSString *sqlvalue = [set stringForColumn:self.name];
    if(![self dataBaseIsValue:sqlvalue])
        return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    NSArray *va = [sqlvalue componentsSeparatedByString:@"---"];
    
    for (int i=0; i<va.count; i+=2) {
        Class clazz = NSClassFromString(va[i+1]);
        NSAssert(clazz != nil, @"数据库值 无法获取class");
        if([clazz isBaseTarget]){
            id value = block(va[i],clazz);
            [array addObject:value];
        }else{
            id value = [self value:va[i] class:clazz];
            [array addObject:value];
        }
    }
    
    
    return array;
}
-(BOOL)isCanSave:(id)value{
    if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]){
        return NO;
    }
    return YES;
}

-(id)value:(NSString *)value class:(Class)class{
    //将数据库字符串存储的值 转为真实 类型
    id real_value;
    if ([class isSubclassOfClass:[NSString class]]){
        real_value = value;
    }else if ([class isSubclassOfClass:[NSNumber class]]){
        real_value = @([value doubleValue]);
    }else{
        //.....
    }
    return real_value;
}
@end
