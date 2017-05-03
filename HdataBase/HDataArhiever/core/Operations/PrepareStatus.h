//
//  PrepareStatus.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DBOperation;
@interface PrepareStatus : NSObject
@property(nonatomic,copy)NSString *sql;
@property(nonatomic,assign)Class valueC;
@property(nonatomic,strong,readonly)NSArray *operations;
//增加操作符
-(PrepareStatus *)addOperation:(DBOperation*)operation;
//得到值
-(id)values;

/**
 当你指定关注的值 可以选择返回值类型
 @return
 */
-(id)valuesForArray;
-(id)valuesForDictionary;
@end

@interface PrepareStatus (simple)

@property(nonatomic,copy,readonly)PrepareStatus*(^AddOperation)(DBOperation * opera);
@end
