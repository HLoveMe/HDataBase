//
//  ArrayProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "ArrayProperty.h"

@implementation ArrayProperty
-(instancetype)init{
    if (self = [super init]) {
        self.vType = isNUll;
    }
    return self;
}
-(NSString *)getReadValue:(long(^)(id<DBArhieverProtocol> obj))block value:(id)value{
    if (block&&value&&[value isKindOfClass:[NSArray class]]){
        NSArray *arr = (NSArray*)value;
        NSString *clas = NSStringFromClass(self.valueClass);
        if (self.vType == isBaseTarget){
            NSMutableArray *res = [NSMutableArray array];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [res addObject:@(block(obj))];
            }];
            [res addObject:clas];
            return [res componentsJoinedByString:@"---"];
        }else{
            return [[arr arrayByAddingObject:clas] componentsJoinedByString:@"---"];
        }
    }else{
        return [Property arraynullValue];
    }
}
-(id)valueWithSet:(id<DBArhieverProtocol> (^)(NSString *, __unsafe_unretained Class))block set:(FMResultSet *)set{
    
    NSString *sqlvalue = [set stringForColumn:self.name];
    if(![self dataBaseIsValue:sqlvalue])
        return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    NSArray *va = [sqlvalue componentsSeparatedByString:@"---"];
    Class clazz = NSClassFromString([va lastObject]);
    NSAssert(clazz != nil, @"数据库值 无法获取class");
    if(block){
        if([clazz isBaseTarget]){
            for (int i=0; i<va.count-1; i++) {
                id value = block(va[i],clazz);
                [array addObject:value];
            }
        }else{
            for (int i=0; i<va.count-1; i++) {
                id value = [self value:va[i] class:clazz];
                [array addObject:value];
            }
        }
    }
    return array;
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
