//
//  NSObject+AddSELDictionary.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/24.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "NSObject+SEL.h"
#import <objc/runtime.h>
#import "NSObject+Base.h"
@implementation NSObject (AddSELDictionary)
//以下是为了 实现SEL的存储和实现的方法

-(id)valueForUndefinedKey:(NSString *)key{
    BOOL base = [self isBaseTarget];
    if (base){
        //无法获取值得情况 为 SEL类型
        NSString *me = [NSString stringWithFormat:@"%@",key];
        SEL as = NSSelectorFromString(me);
        NSMethodSignature *sing = [self methodSignatureForSelector:as];
        NSInvocation *invoca = [NSInvocation invocationWithMethodSignature:sing];
        [invoca setSelector:as];
        [invoca invokeWithTarget:self];
        SEL asel;
        [invoca getReturnValue:&asel];
        return [NSValue  value:&asel withObjCType:@encode(SEL)];
    }
    return nil;
}
-(NSMutableDictionary *)addSelDictionary;{
    NSMutableDictionary *dic = objc_getAssociatedObject(self, "SELBOXS");
    if (dic == nil){
        dic = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, "SELBOXS", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSValue*(^IM)(id _self,SEL __cmd,NSString *key) = ^NSValue*(id _self,SEL __cmd,NSString *key){
            NSMutableDictionary *sels = objc_getAssociatedObject(_self, "SELBOXS");
            NSValue *value = sels[key];
            if (value == nil){
                return nil;
            }
            return value;
        };
        
        IMP imp = imp_implementationWithBlock(IM);
        const char *type = "@@:@";
        class_addMethod([self class], @selector(selBoxs:), imp, type);
    }
    return dic;
}

@end
