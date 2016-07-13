//
//  ivarInfomation.h
//  数据库测试
//
//  Created by 朱子豪 on 16/7/8.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@interface ivarInfomation : NSObject
//属性名字
@property(nonatomic,copy)NSString *proName;
//属性值
@property(nonatomic,strong)id proValue;
@property(nonatomic,assign)Class valueClass;
@property(nonatomic,assign)BOOL isFundation;

//该属性是否为数组
@property(nonatomic,assign)BOOL isArray;
//数组下元素的clazz
@property(nonatomic,assign)Class arrClazz;
@property(nonatomic,assign)BOOL arrIsFundation;

@property(nonatomic,assign)objc_property_t pro;

@end
