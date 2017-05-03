//
//  PrerequisiteOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "DBOperation.h"

@interface PrerequisiteOperation : DBOperation
//表示条件 and  or  在两个条件以上需要指定 默认为and
@property(nonatomic,assign)BOOL isAnd;
@property(nonatomic,copy)NSString *content;
@end
