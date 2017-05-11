//
//  NSObject+Base.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "NSObject+Base.h"
#import "IvarInfomation.h"
#import "ClassManager.h"
#import "DBBaseTarget.h"
#import "PropertyFactory.h"
#import "DBPlugBox.h"
#import "DBPlug.h"
@implementation NSObject (Base)
-(void)enumerateObjectsUsingBlock:(void(^)(IvarInfomation *info))Block{
    void(^oneStep)(Class temp)=^(Class temp){
        DBPlugBox *box = [DBPlugBox shareBox];
        DBPlug *plug = [box plugFor:temp];
        [self db_enumerateClazz:temp propertys:^(objc_property_t t, NSString *name, id value) {
            IvarInfomation *ivar = [[IvarInfomation alloc]init];
            ivar.value = value;
            Property *property = [PropertyFactory propertyWith:t value:value];
            ivar.property = property;
            if (Block){
                if(plug){
                    if([plug isCanSaveToDB:ivar class:temp])
                        Block(ivar);
                }else{
                    Block(ivar);
                }
            }
            
        }];
    };
    BOOL go=YES;
    Class clazz=[self class];
    while (go&&clazz) {
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
    while (go&&clazz) {
        if ([clazz isBaseTarget]) {
            oneStep(clazz);
            clazz=[clazz superclass];
        }else{
            go=NO;
        }
    }
}
+(void)enumerateIvar2:(void (^)(NSString *name,NSString *type))Block{
    if(!Block){return;}
    id va = [[self alloc]init];
    void(^oneStep)(Class temp)=^(Class temp){
        [va db_enumerateClazz:temp propertys:^(objc_property_t t, NSString *name, id value) {
            NSString *att =[NSString stringWithUTF8String:property_getAttributes(t)];
            NSString *onepart = [[att componentsSeparatedByString:@","] firstObject];
            NSString *encode = [onepart substringWithRange:NSMakeRange(1, onepart.length-1)];
            Block(name,encode);
        }];
    };
    BOOL go=YES;
    Class clazz=[self class];
    while (go&&clazz) {
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
    NSMutableArray * fileds = [[NSObject autoIgnores] mutableCopy];
    if ([self isBaseTarget]){
        if([self respondsToSelector:@selector(ignoreFileds)]){
            NSArray *ignore = [(id<DBArhieverProtocol>)self ignoreFileds];
            if (ignore != nil){
                [fileds addObjectsFromArray:ignore];
            }
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
    NSMutableArray * fileds = [[NSObject autoIgnores] mutableCopy];
    if ([self isBaseTarget]){
        if([self respondsToSelector:@selector(ignoreFileds)]){
            NSArray *ignore = [(id<DBArhieverProtocol>)self ignoreFileds];
            if (ignore != nil){
                [fileds addObjectsFromArray:ignore];
            }
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
    return [[self class] isBaseTarget];
}
+(BOOL)isBaseTarget{
    return [self isimplementationProtocol:@"DBArhieverProtocol"];
}
+(BOOL)isimplementationProtocol:(NSString *)proName{
    if ([self isSubclassOfClass:[DBBaseTarget class]]){
        return YES;
    }
    BOOL(^oneStep)(Class this) = ^BOOL(Class this){
        unsigned int num;
        Protocol * __unsafe_unretained *pros = class_copyProtocolList([self class], &num);
        BOOL flag = NO;
        for (int i=0; i<num; i++) {
            Protocol *one = pros[i];
            NSString *name = [NSString stringWithUTF8String:protocol_getName(one)];
            if ([name isEqualToString:proName]){
                flag = YES;
                break;
            }
        }
        free(pros);
        return flag;
    };
    
    BOOL go=YES;
    BOOL result = NO;
    Class clazz=[self class];
    while (go&&clazz) {
        BOOL result = oneStep(clazz);
        if(result){
            go = NO;
        }else{
            clazz = [clazz superclass];
        }
    }
    return result;
}
-(BOOL)isEnCode{
    return [ClassManager isEnCode:self];
}
+(BOOL)isEnCode{
    return [ClassManager isEnCode:[self new]];
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
