//
//  ORDEROperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "AssistOperation.h"

@interface ORDEROperation : AssistOperation

/**
 排序属性

 @param content @"age" 升序  @"-age" 降序
 @return self
 */
+(instancetype)Operation:(NSString *)name;
@end
