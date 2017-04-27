//
//  PropertyFactory.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//


#import "ClassManager.h"
#import "NSObject+Base.h"
#import "DBBaseTargetProtocol.h"
#import "propertys.h"
@implementation PropertyFactory

+(Property *)propertyWith:(objc_property_t) t value:(id)value{
    NSString *att =[NSString stringWithUTF8String:property_getAttributes(t)];
    NSString *onepart = [[att componentsSeparatedByString:@","] firstObject];
    NSString *encode = [onepart substringWithRange:NSMakeRange(1, onepart.length-1)];
    Property *pro;
    if ([encode containsString:@"\""]){
        //对象  数组   一定是可序列 或者协议对象
        encode = [encode substringWithRange:NSMakeRange(2, encode.length-3)];
        
        if([encode containsString:@"Array"]){
            ArrayProperty *arrP = [[ArrayProperty alloc]init];
            //数组
            if(value!=nil && [(NSArray *)value count]>=1){
                //                arrP.valueClass = [tar class];
                NSArray * temp = (NSArray *)value;
                NSMutableArray *types = [NSMutableArray array];
                NSMutableArray *clas = [NSMutableArray array];
                for (int i=0; i<temp.count; i++) {
                    NSObject *tar = [(NSArray *)value firstObject];
                    BOOL code = [tar isEnCode];
                    BOOL base = [tar isBaseTarget];
                    if (code || base){
                        if(code && base){
                            [types addObject:@(isBaseTarget)];
                        }else if (code){
                            [types addObject:@(isEnCode)];
                        }else{
                            [types addObject:@(isBaseTarget)];
                        }
                    }else{
                        NSAssert(NO, @"该数组属性  值 不可保存");
                    }
                    [clas addObject:[ClassManager valueClass:tar]];
                }
                arrP.vTypes = types;
                arrP.valuesClazzs = clas;
            }
            arrP.type = encode;
            arrP.proClass = [NSArray class];
            pro = arrP;
        }else if([encode containsString:@"Dictionary"]){
            DictionaryProperty *dicp = [[DictionaryProperty alloc]init];
            dicp.type = encode;
            dicp.proClass = [NSDictionary class];
            
            if(value && [(NSDictionary *)value allKeys].count >=1 ){
                NSDictionary * temp = (NSDictionary *)value;
                NSMutableArray *types = [NSMutableArray array];
                NSMutableArray *clas = [NSMutableArray array];
                
                [temp enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    BOOL code = [obj isEnCode];
                    BOOL base = [obj isBaseTarget];
                    if (code || base){
                        if(code && base){
                            [types addObject:@(isBaseTarget)];
                        }else if (code){
                            [types addObject:@(isEnCode)];
                        }else{
                            [types addObject:@(isBaseTarget)];
                        }
                    }else{
                        NSAssert(NO, @"该数组属性  值 不可保存");
                    }
                    [clas addObject:[ClassManager valueClass:obj]];
                }];
                dicp.vTypes = types;
                dicp.valuesClazzs = clas;
            }
            pro = dicp;
        }else{
            Property *_temp;
            Class clazz = NSClassFromString(encode);
            NSAssert(clazz != nil, @"encode -class fail");
            if ([clazz isBaseTarget]){
                TargetProperty *tar = [[TargetProperty alloc]init];
                tar.type = encode;
                tar.proClass = clazz;
                _temp = tar;
            }else if([clazz isEnCode]){
                GeneralProperty *gen = [[GeneralProperty alloc]init];
                
                gen.proClass = clazz;
                gen.type = encode;
                NSAssert(gen.proClass != nil, @"value encode class fail");
                _temp = gen;
            }else{
                NSAssert(NO, @"必须是可序列化 和实现协议对象 实现协议去掉该属性");
            }
            pro = _temp;
        }
        
    }else if([encode containsString:@"{"]){
        pro =[StructProperty new];
        //结构体 CGRange  NSRange
        //@"{CGRect={CGPoint=dd}{CGSize=dd}}"
        //@"{_NSRange=QQ}"
        //@"{CGSize=dd}"
        //@"{CGPoint=dd}"
        pro.type = @"{";
        
    }else if([encode containsString:@"@"]){
        //id 类型
        if(value){
            BOOL base = [value isBaseTarget];
            BOOL code = [value isEnCode];
            Property *_pro ;
            if(base || code){
                Class _clazz = [ClassManager valueClass:value];
                if (base) {
                    _pro = [[TargetProperty alloc]init];
                }else{
                    _pro = [[GeneralProperty alloc]init];
                }
                _pro.type = @"@";
                _pro.proClass = _clazz;
            }else{
                NSAssert(NO, @"该 id 值 不支持数据库保存");
            }
            pro = _pro;
        }else{
            //默认字符串
            pro = [[GeneralProperty alloc]init];
        }
    }else if([encode containsString:@"#"]){
        //Class
        pro = [[ClassProperty alloc]init];
        pro.type = @"#";
    }else if([encode containsString:@":"]){
        //        SEL
        pro = [[SELProperty alloc]init];
        pro.type = @":";
    }else{
        NumberProperty *gen = [[NumberProperty alloc]init];
        gen.proClass = [NSNumber class];
        gen.type = encode;
        pro = gen;
    }
    pro.name = [NSString stringWithUTF8String:property_getName(t)];;
    pro.t = t;
    
    NSAssert(pro != nil,@"只是不支持属性");
    return pro;
}

@end
