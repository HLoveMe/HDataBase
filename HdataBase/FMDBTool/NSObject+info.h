//
//  NSObject+info.h
//  数据库测试
//
//  Created by 朱子豪 on 16/7/8.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ivarInfomation;
@interface NSObject (info)
-(void)enumerateObjectsUsingBlock:(void(^)(ivarInfomation *info))Block;

-(void)enumeratePropertyValue:(void(^)(NSString *proName,id value))Block;
-(NSString *)toString;
+(instancetype)objectWithDictionaryString:(NSString *)dicStr clazz:(Class)clazz;
@end
