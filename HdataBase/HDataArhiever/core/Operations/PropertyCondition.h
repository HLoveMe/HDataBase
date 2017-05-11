//
//  PropertyCondition.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/10.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
//仅仅针对 JOIN操作

@interface PropertyCondition : NSObject
//target Class
@property(nonatomic,assign)Class clazz;
//target Property Name
@property(nonatomic,copy)NSString *name;

+(instancetype)Condition:(NSString *)name clazz:(Class)clazz;


//得到[People__address] 用于结果的key  别名
-(NSString *)propertyName;

//t_table.name
-(NSString *)tableProName;

//JOIn     (t_table.name AS 别名)
-(NSString *)description;

+(NSString *)spearaStr;
@end
