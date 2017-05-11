//
//  LeftOUTEROperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/10.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "JoinOperation.h"

@interface LeftOUTEROperation : JoinOperation

/**
    A LEFT OUTER Join B
    1: A 的所有行
                    1        2       3       4
         A1  满足    x        x       x       x
         A2 不满足   null      null   null    null
 
 
        ...
        A100
    2: B 满足条件的  对应显示
    3: B 不满足的 NULL值
 */
@end
