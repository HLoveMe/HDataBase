//
//  NSObject+info.m
//  数据库测试
//
//  Created by 朱子豪 on 16/7/8.
//  Copyright © 2016年 Space. All rights reserved.
//

#import "NSObject+info.h"
#import "ivarInfomation.h"
#import <objc/runtime.h>
@implementation NSObject (info)
-(void)enumerateObjectsUsingBlock:(void(^)(ivarInfomation *info))Block{
    void(^oneStep)(Class temp)=^(Class temp){
        unsigned int  count;
        objc_property_t *pros = class_copyPropertyList([temp class], &count);
        for (int i=0; i<count; i++) {
            NSString *name =[NSString stringWithUTF8String:property_getName(pros[i])];
            id  value = [self valueForKey:name];
            ivarInfomation *ivar = [[ivarInfomation alloc]init];
            ivar.proName=name;
            ivar.proValue=value;
            ivar.pro=pros[i];
            
            NSString *one = [NSString stringWithUTF8String:property_getAttributes(pros[i])];
            if([one containsString:@"NSArray"] | [one containsString:@"NSMutableArray"]){
                ivar.isArray=YES;
                if (value) {
                    ivar.arrClazz=[[(NSArray *)value firstObject] class];
                    NSString *temp = NSStringFromClass(ivar.arrClazz);
                    if ([temp hasPrefix:@"NS"]|[temp containsString:@"NSCFNumber"]) {
                        ivar.arrIsFundation=1;
                    }
                }
            }else{
                NSString *temp = [one componentsSeparatedByString:@","][0];
                if([temp containsString:@"@"]){
                    temp=[temp substringWithRange:NSMakeRange(3, temp.length-4)];
                    ivar.valueClass=NSClassFromString(temp);
                    ivar.isFundation=[[temp substringToIndex:2] isEqualToString:@"NS"]|[temp containsString:@"NSCFNumber"];
                }else{
                    ivar.valueClass=[NSNumber class];
                    ivar.isFundation=YES;
                }
            }
            
            Block(ivar);
        }
        
    };
    BOOL go=YES;
    Class clazz=[self class];
    while (go) {
        if (clazz==[NSObject class]) {
            go=NO;
        }else{
            oneStep(clazz);
            clazz=[clazz superclass];
        }
    }
}


-(void)enumeratePropertyValue:(void(^)(NSString *proName,id value))Block{
    void(^oneStep)(Class temp)=^(Class temp){
        unsigned int  count;
        objc_property_t *pros = class_copyPropertyList([temp class], &count);
        for (int i=0; i<count; i++) {
            NSString *name =[NSString stringWithUTF8String:property_getName(pros[i])];
            id  value = [self valueForKey:name];
            Block(name,value);
        }
        
    };
    BOOL go=YES;
    Class clazz=[self class];
    while (go) {
        if (clazz==[NSObject class]) {
            go=NO;
        }else{
            oneStep(clazz);
            clazz=[clazz superclass];
        }
    }
    
}
-(NSString *)toString{
    NSMutableString *str = [NSMutableString stringWithString:@"{"];
    [self enumerateObjectsUsingBlock:^(ivarInfomation *info) {
        if (info.isArray) {
            NSArray *array=(NSArray *)info.proValue;
            NSMutableString *temp = [NSMutableString stringWithString:@"[ "];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (info.arrIsFundation) {
                    [temp appendFormat:@"%@,",obj];
                }else{
                    [temp appendFormat:@"%@,",[obj toString]];
                }
            }];
            temp=[temp substringToIndex:temp.length-1].mutableCopy;
            
            [temp appendFormat:@"{\"clazz\":\"%@\"}",info.arrClazz];
            [temp appendString:@"]"];
            
            
            [str appendFormat:@"\"%@\":%@,",info.proName,temp];
            
        }else if (!info.isFundation){
            NSString *temp = [info.proValue toString];
            [str appendFormat:@"\"%@\":\"%@\",",info.proName,temp];
        }else{
            [str appendFormat:@"\"%@\":\"%@\",",info.proName,info.proValue];
        }
        
    }];
    str = [str substringToIndex:str.length-1].mutableCopy;
    [str appendString:@"}"];
    return str;
}
+(instancetype)objectWithDictionaryString:(NSString *)dicStr clazz:(Class)clazz{
    id this = [[clazz alloc]init];
    NSDictionary *dic =[NSJSONSerialization JSONObjectWithData:[dicStr dataUsingEncoding:4] options:0 error:nil];
    NSAssert(dic, @"解析错误");
    NSDictionary *pro;
    if([clazz respondsToSelector:@selector(dataMigrate)]){
        pro = [clazz performSelector:@selector(dataMigrate)];
    }
    [this enumerateObjectsUsingBlock:^(ivarInfomation *info) {
        id str = dic[info.proName];
        if(!str){str = dic[pro[info.proName]];}
        if (info.isArray) {
            NSArray *a = dic[info.proName];
            Class clazz = NSClassFromString(a.lastObject[@"clazz"]);
            NSMutableArray *arr =[NSMutableArray array];
            if (clazz){
                NSArray *con=str;
                for (int i=0; i<con.count-1; i++) {
                    id one =[[clazz alloc]init];
                    [one setValuesForKeysWithDictionary:con[i]];
                    [arr addObject:one];
                }
            }
            [this setValue:arr forKey:info.proName];
        }else if (!info.isFundation){
            [this setValue:[NSObject objectWithDictionaryString:str clazz:info.valueClass ] forKey:info.proName];
        }else{
            if ([NSStringFromClass(info.valueClass) containsString:@"String"]) {
                [this setValue:str forKey:info.proName];
            }else{
                [this setValue:@([str doubleValue]) forKey:info.proName];
            }
        }
    }];
    return this;
}
@end
