//
//  JoinOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/10.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "DBOperation.h"

@interface JOINModel : NSObject

@end

@interface JoinOperation : DBOperation

-(NSString *)content:(Class )target;

/**
 创建
    select * from A [X] join B using (name)
 
 == select * from A [X] join B on  A.name = B.name
 @param class 关联表
 @param condition 条件   （NSSTring, [NSString]）  默认为"oneself"
 @return self
 */
-(instancetype)initOperationJoin:(Class)class with:(id)condition;

//select * from A  [X] join B on A.name = B.Xname
/**
 *   self: @[@"A",@"B"]   
 *  other: @[@"AA",@"BB"] @[@(YES)]
 *  compares:@[@"=",@">"]  // nil(=)
 *    TableA.A = TableB.AA YES/NO(and/or) TAbleA.B > TableB.BB
 */

-(instancetype)initOperationJoin:(Class)class self:(NSArray *)ProAs other:(NSArray *)ProBs compare:(NSArray *)compares con:(NSArray<NSNumber*>*)ands;
@end
