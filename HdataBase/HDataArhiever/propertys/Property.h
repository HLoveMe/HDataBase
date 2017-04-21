//
//  PropertyMessage.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/20.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "DBBaseTargetProtocol.h"
#import "NSObject+Base.h"
#import "FMResultSet.h"
typedef NS_ENUM(NSInteger, ValueType) {
    isNUll = 0,
    isEnCode = 1,
    isBaseTarget = 2
};
@interface Property : NSObject
@property(nonatomic,copy)NSString *type;

@property(nonatomic,copy)NSString *name;

@property(nonatomic,assign)Class proClass;

@property(nonatomic,assign)objc_property_t t;

//判断数据库的值是否有效 __NULL__  _ARRAY_NULL_ 无效
-(BOOL)dataBaseIsValue:(NSString *)current;
//得到值为null  替换的值
+(NSString *)nullValue;
+(NSString *)arraynullValue;

//用于获取值  用于保存数据库
/**
    block 为了解决 属性不是可直接保存的情况
    value  该属性值
 */
-(NSString *)getReadValue:(long(^)(id<DBArhieverProtocol> obj))block value:(id)value;
/**
    解析数据库的值
 */
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set;




/***
//@property(nonatomic,copy)NSString *test;
 type = "NSString"
 name = @"test"
 proclass = NSString
 
 
 @property(nonatomic,assign)BOOL test;
 type = "B"
 name = @"test"
 proclass = NSNumber
 */
@end
