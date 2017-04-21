//
//  ivarInfomation.h
//  数据库测试
//
//  Created by 朱子豪 on 16/7/8.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Property.h"
@interface IvarInfomation : NSObject
//属性值
@property(nonatomic,strong)id value;

@property(nonatomic,strong)Property *property;

@end
