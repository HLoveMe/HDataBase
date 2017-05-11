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


/**
 
 你没有进行Join查询 将会返回数组 包含所有结果的数组
 进行Join 查询
    没有指定字段  结果为 valueC对象 (根据查询结果创建对象 有重复)
    指定字段    根据字段返回
 @return result
 */
-(id)values;
/**
 当你指定关注的值 可以选择返回值类型
 @return
 */
-(id)valuesForArray;
-(id)valuesForDictionary;

//+(Class)valueC;
@end

@interface PrepareStatus (simple)
@property(nonatomic,copy,readonly)PrepareStatus*(^AddOperation)(DBOperation * opera);
@end
