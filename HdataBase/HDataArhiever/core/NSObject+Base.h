//
//  NSObject+Base.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>
@class IvarInfomation;
@interface NSObject (Base)
//判断是否为
+(BOOL)isBaseTarget;
-(BOOL)isBaseTarget;
//判断是否可以序列换
-(BOOL)isEnCode;
+(BOOL)isEnCode;

//遍历本类 和 父类
-(void)enumerateObjectsUsingBlock:(void(^)(IvarInfomation *info))Block;

-(void)enumeratePropertyValue:(void(^)(NSString *proName,id value))Block;

+(void)enumerateIvar:(void(^)(NSString *proName))Block;


//辅助函数

-(void)db_enumerateClazz:(Class)clazz propertys:(void(^)(objc_property_t t,NSString *name,id value))block;

-(void)db_enumerateClazz:(Class)clazz ivars:(void(^)(Ivar t,NSString *name,id value))block;

+(void)db_enumeratePropertys:(void(^)(objc_property_t t,NSString *name))block;

+(void)db_enumerateIvars:(void(^)(Ivar t,NSString *name))block;
@end
