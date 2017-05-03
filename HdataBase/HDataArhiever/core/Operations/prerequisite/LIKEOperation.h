//
//  LIKEOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "PrerequisiteOperation.h"

@interface LIKEOperation : PrerequisiteOperation

/**
 指定LIKE 条件 //模糊匹配   
 %   : 代表零个、一个或多个数字或字符
 _   : 代表一个单一的数字或字符
 
 name 以ZZH结尾    proName=@"name"  content = @"%ZZH"
 name 以ZZH开头    proName=@"name"  content = @"ZZH%"
 name 包含ZZH即可  proName=@"name"  content = @"%ZZH%"
 
 WHERE SALARY LIKE '2_%_%'	查找以 2 开头，且长度至少为 3 个字符的任意值
 WHERE SALARY LIKE '_2%3'	查找第二位为 2，且以 3 结尾的任意值
 
 @param proName 属性名
 @param content 条件
 @return self
 */
+(instancetype)Operation:(NSString *)proName like:(NSString *)content;
// where  A and/or b
+(instancetype)Operation:(NSString *)proName like:(NSString *)content and:(BOOL)isAnd;
@end
