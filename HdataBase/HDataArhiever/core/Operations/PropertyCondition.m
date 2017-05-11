//
//  PropertyCondition.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/10.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "PropertyCondition.h"
#import "DataBaseConnect.h"
@implementation PropertyCondition
+(instancetype)Condition:(NSString *)name clazz:(Class)clazz{
    PropertyCondition *pc = [PropertyCondition new];
    pc.name = name;
    pc.clazz = clazz;
    return pc;
}
+(NSString *)spearaStr{
    return @"__";
}
-(NSString *)propertyName{
    return [NSString stringWithFormat:@"%@%@%@",self.clazz,[PropertyCondition spearaStr],self.name];
}
-(NSString *)tableProName{
    return [NSString stringWithFormat:@" %@.%@",[DataBaseConnect tableName:_clazz],_name];
}

-(NSString *)description{
    return  [NSString stringWithFormat:@" %@ AS %@",self.tableProName,self.propertyName];
}
@end
