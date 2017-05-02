//
//  ArrayProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "ArrayProperty.h"
#import "GeneralProperty.h"
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
        [res addObject:@"Array"];
        return [res componentsJoinedByString:[Property separatedString]];
    }else{
        return [Property arraynullValue];
    }
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set sqlV:(NSString *)sqlV class:(Class)c{
    if(!block){return @[];}
    if(!sqlV)return nil;
    if(![Property dataBaseIsValue:sqlV])
        return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    NSArray *va = [sqlV componentsSeparatedByString:[Property separatedString]];
    
    for (int i=0; i<va.count-1; i+=2) {
        Class clazz = NSClassFromString(va[i+1]);
        NSAssert(clazz != nil, @"数据库值 无法获取class");
        if([clazz isBaseTarget]){
            id value = block(va[i],clazz);
            [array addObject:value];
        }else{
            id value = [GeneralProperty valueWithstr:va[i] class:clazz];
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

@end
