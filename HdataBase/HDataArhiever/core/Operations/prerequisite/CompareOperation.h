//
//  CompareOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "PrerequisiteOperation.h"
typedef enum {
    A,//>
    B,//=
    C,//<
    D,//>=
    E//<=
}FMDBCompare;
@interface CompareOperation : PrerequisiteOperation
/**
    where age > 18
    where tableName.age > 18  针对内联
 */
//msg 为 NSString(属性名称) or  PropertyCondition
//PropertyCondition  针对join
+(instancetype)Operation:(id)msg compare:(FMDBCompare)compare value:(double)va and:(BOOL)isAnd;

@end
