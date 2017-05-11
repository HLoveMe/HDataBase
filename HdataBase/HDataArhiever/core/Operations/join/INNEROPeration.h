//
//  INNEROPeration.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/10.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "JoinOperation.h"

@interface INNEROPeration : JoinOperation
//内连接  查询会把 table1 中的每一行与 table2 中的每一行进行比较，找到所有满足连接谓词的行的匹配对
// SELECT ... FROM table1 JOIN table2 USING ( name )   匹配name相同的
//select * From t_Author inner join t_People using(oneself)

//select * From t_Author inner join t_People on t_Author.oneself == t_People.oneself   where t_People.alalry>=20000
@end
