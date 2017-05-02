//
//  generalProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "GeneralProperty.h"
@implementation GeneralProperty
//得到插入数据库的值
+(NSString *)realValue:(id)va{
    if([va isKindOfClass:[NSString class]]||[va isKindOfClass:[NSNumber class]]){
        //NSString NSNumber
        return [[NSString alloc]initWithFormat:@"%@",va];
    }else if([va isKindOfClass:[NSURL class]]){
        //NSURL
        return [(NSURL *)va absoluteString];
    }else if([va isKindOfClass:[NSDate class]]){
        //NSDate
        return [[NSString alloc]initWithFormat:@"%f",[(NSDate *)va timeIntervalSince1970]];
    }
//    ...ClassManager  增加isEnCode
//    ... 增加 解析
    return [Property nullValue];
}
+(id)valueWithstr:(NSString *)str class:(Class)class{
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
    return value ? [GeneralProperty realValue:value] : [Property nullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set sqlV:(NSString *)sqlV class:(Class)clazz{
    if(!sqlV)return nil;
    if([Property dataBaseIsValue:sqlV]){
        id va  = [GeneralProperty valueWithstr:sqlV class:clazz];
        return va;
    }
    return nil;
}
@end
