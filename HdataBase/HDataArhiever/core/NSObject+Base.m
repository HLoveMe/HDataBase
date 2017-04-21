//
//  NSObject+Base.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "NSObject+Base.h"
#import "IvarInfomation.h"
#import "classExtension.h"
#import "DBBaseTarget.h"
#import "PropertyFactory.h"
@implementation NSObject (Base)
-(void)enumerateObjectsUsingBlock:(void(^)(IvarInfomation *info))Block{
    void(^oneStep)(Class temp)=^(Class temp){
        [self db_enumerateClazz:temp propertys:^(objc_property_t t, NSString *name, id value) {
            IvarInfomation *ivar = [[IvarInfomation alloc]init];
            ivar.value = value;
            Property *property = [PropertyFactory propertyWith:t value:value];
            ivar.property = property;
            if (Block)
                Block(ivar);
        }];
    };
    BOOL go=YES;
    Class clazz=[self class];
    while (go) {
        if ([clazz isBaseTarget]) {
            oneStep(clazz);
            clazz=[clazz superclass];
        }else{
            go=NO;
        }
    }
}

-(void)enumeratePropertyValue:(void(^)(NSString *proName,id value))Block{
    void(^oneStep)(Class temp)=^(Class temp){
        [self db_enumerateClazz:temp propertys:^(objc_property_t t, NSString *name, id value) {
            if (Block)
                Block(name,value);
        }];
    };
    BOOL go=YES;
    Class clazz=[self class];
    while (go) {
        if ([clazz isBaseTarget]) {
            oneStep(clazz);
            clazz=[clazz superclass];
        }else{
            go=NO;
        }
    }
}
+(void)enumerateIvar:(void(^)(NSString *proName))Block{
    [[[self alloc]init] enumeratePropertyValue:^(NSString *proName, id value) {
        if (Block)
            Block(proName);
    }];
}
//辅助
-(void)db_enumerateClazz:(Class)clazz propertys:(void(^)(objc_property_t t,NSString *name,id value))block{
    unsigned int  count;
    NSArray * fileds = [NSObject autoIgnores];
    if ([self isBaseTarget]){
        if([self respondsToSelector:@selector(dbFileds)]){
            NSArray *temp = [(id<DBArhieverProtocol>)self dbFileds];
            if (temp != nil){fileds = [fileds arrayByAddingObjectsFromArray:temp];}
        }
    }
    objc_property_t *pros = class_copyPropertyList(clazz, &count);
    for (int i=0; i<count; i++) {
        objc_property_t t = pros[i];
        NSString *name =[NSString stringWithUTF8String:property_getName(t)];
        if(fileds == nil || ![fileds containsObject:name] || fileds.count == 0){
            id  value = [self valueForKey:name];
            if (block){block(t,name,value);}
        }
        
    }
}
-(void)db_enumerateClazz:(Class)clazz ivars:(void(^)(Ivar t,NSString *name,id value))block{
    unsigned int count ;
    NSArray * fileds = [NSObject autoIgnores];
    if ([self isBaseTarget]){
        if([self respondsToSelector:@selector(dbFileds)]){
            NSArray *temp = [(id<DBArhieverProtocol>)self dbFileds];
            if (temp != nil){fileds = [fileds arrayByAddingObjectsFromArray:temp];}
        }
    }
    
    Ivar *ivars = class_copyIvarList(clazz, &count);
    for (int i=0; i<count; i++) {
        Ivar one  = ivars[i];
        NSString *name = [[NSString alloc]initWithUTF8String:ivar_getName(one)];
        name = [name substringFromIndex:1];
        if(fileds == nil || ![fileds containsObject:name] || fileds.count == 0){
            id  value = [self valueForKey:name];
            if(block){block(one,name,value);}
        }
    }
}
+(void)db_enumeratePropertys:(void(^)(objc_property_t t,NSString *name))block{
    id target = [[self alloc]init];
    [target db_enumerateClazz:[self class] propertys:^(objc_property_t t, NSString *name, id value) {
        if (block)
            block(t,name);
    }];
}

+(void)db_enumerateIvars:(void(^)(Ivar t,NSString *name))block{
    id target = [[self alloc]init];
    [target db_enumerateClazz:[self class] ivars:^(Ivar t, NSString *name, id value) {
        if (block)
            block(t,name);
    }];
}
//判断是否满足写入数据库条件
-(BOOL)isBaseTarget{
    if ([self isKindOfClass:[DBBaseTarget class]]){
        return YES;
    }
    
    unsigned int num;
    Protocol * __unsafe_unretained *pros = class_copyProtocolList([self class], &num);
    BOOL flag = NO;
    for (int i=0; i<num; i++) {
        Protocol *one = pros[i];
        NSString *name = [NSString stringWithUTF8String:protocol_getName(one)];
        if ([name isEqualToString:@"DBArhieverProtocol"]){
            flag = YES;
            break;
        }
    }
    free(pros);
    return flag;
}
+(BOOL)isBaseTarget{
    if ([self isSubclassOfClass:[DBBaseTarget class]]){
        return YES;
    }
    
    unsigned int num;
    Protocol * __unsafe_unretained *pros = class_copyProtocolList([self class], &num);
    BOOL flag = NO;
    for (int i=0; i<num; i++) {
        Protocol *one = pros[i];
        NSString *name = [NSString stringWithUTF8String:protocol_getName(one)];
        if ([name isEqualToString:@"DBArhieverProtocol"]){
            flag = YES;
            break;
        }
    }
    free(pros);
    return flag;
}
-(BOOL)isEnCode{
    if ([self respondsToSelector:@selector(encodeWithCoder:)] && [self respondsToSelector:@selector(initWithCoder:)]){
        return YES;
    }
    return NO;
}
+(BOOL)isEnCode{
    return [[[self alloc]init]isEnCode];
}
+(NSArray*)autoIgnores{
    static  NSArray *fileds;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        //属于NSOBject 的属性
        fileds =  @[@"hash",@"superclass",@"description",@"debugDescription"];
    });
    return fileds;
}
@end
