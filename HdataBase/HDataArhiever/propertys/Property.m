
//
//  PropertyMessage.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/20.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "Property.h"
@implementation Property
+(NSString *)separatedString{
    return @"-|-|-|-";
}
+(NSString *)nullValue{
    static NSString *null;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        null = @"_NULL_";
    });
    return null;
}
+(NSString *)arraynullValue{
    static NSString *null;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        null = @"_ARRAY_NULL_";
    });
    return null;
}
+(NSString *)dictionarynullValue{
    static NSString *null;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        null = @"_DICTIONARY_NULL_";
    });
    return null;
}

+(BOOL)dataBaseIsValue:(NSString *)current{
    if ([current isEqualToString:[Property nullValue]] || [current isEqualToString:[Property arraynullValue]] || [current isEqualToString:[Property dictionarynullValue]] ){
        return NO;
    }
    return YES;
}


-(NSString *)getReadValue:(long(^)(id<DBArhieverProtocol> obj))block value:(id)value{
    return (value ? [value description] : [Property nullValue]);
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set sqlV:(NSString *)sqlV class:(Class)clazz{
    if(!sqlV)return nil;
    return ([Property dataBaseIsValue:sqlV] ? sqlV : nil);
}
@end
