//
//  ValueOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "DBOperation.h"

@interface ValueOperation : DBOperation
//表示想要查询的属性
@property(nonatomic,strong)NSMutableArray *pros;
//查询的字段
// pros 元素  NSString(属性名称) or  PropertyCondition
+(instancetype)Operation:(NSArray *)pros;

////名字 别名
//@property(nonatomic,strong)NSMutableArray *asNames;
//+(instancetype)Operation2:(NSDictionary<NSString *,NSString *> *)proNames;
@end
