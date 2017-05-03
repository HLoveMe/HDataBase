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
@property(nonatomic,strong)NSMutableArray *names;

+(instancetype)Operation:(NSArray *)proNames;

////名字 别名
//@property(nonatomic,strong)NSMutableArray *asNames;
//+(instancetype)Operation2:(NSDictionary<NSString *,NSString *> *)proNames;
@end
