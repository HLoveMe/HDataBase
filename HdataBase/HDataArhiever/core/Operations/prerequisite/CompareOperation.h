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
//select * from Author where age > 1
+(instancetype)Operation:(NSString *)name compare:(FMDBCompare)compare value:(double)va;

// where  A and/or b
+(instancetype)Operation:(NSString *)name compare:(FMDBCompare)compare value:(double)va and:(BOOL)isAnd;
@end
