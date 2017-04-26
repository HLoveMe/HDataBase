//
//  generalProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "GeneralProperty.h"
@implementation GeneralProperty
-(NSString *)realValue:(id)va{
    if([va isKindOfClass:[NSString class]]||[va isKindOfClass:[NSNumber class]]){
        return [[NSString alloc]initWithFormat:@"%@",va];
    }else if([va isKindOfClass:[NSURL class]]){
        return [(NSURL *)va absoluteString];
    }else if([va isKindOfClass:[NSDate class]]){
        return [[NSString alloc]initWithFormat:@"%f",[(NSDate *)va timeIntervalSince1970]];
    }
//    ... 增加isEnCode
//    ... 增加 解析
    return [Property nullValue];
}
-(id)valueWithstr:(NSString *)str class:(Class)class{
    if(!class)return nil;
    if([class isSubclassOfClass:[NSString class]]){
        //NSString
        return str;
    }else if([class isSubclassOfClass:[NSNumber class]]){
        //NSNumber
        return [NSNumber numberWithDouble:[str doubleValue]];
    }else if([class isSubclassOfClass:[NSURL class]]){
        //NSURL
        return [[NSURL alloc]initWithString:str];
    }else if([class isSubclassOfClass:[NSDate class]]){
        //NSDate
        return [NSDate dateWithTimeIntervalSince1970:[str doubleValue]];
    }
    return str;
}
-(NSString *)getReadValue:(long (^)(id<DBArhieverProtocol>))block value:(id)value{
    NSString *temp = [self realValue:value];
    return value ? temp : [Property nullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set class:(Class)clazz{
    NSString *sqlv = [set stringForColumn:self.name];
    if([self dataBaseIsValue:sqlv]){
        id va  = [self valueWithstr:sqlv class:clazz];
        return va;
    }
    return nil;
}
@end
