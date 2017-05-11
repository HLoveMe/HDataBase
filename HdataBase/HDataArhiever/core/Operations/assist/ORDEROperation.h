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
    降序和升序

 @param content @"age" 升序  @"-age" 降序
 @return self
 //msg 为 NSString(属性名称) or  PropertyCondition
 //PropertyCondition  针对join
 */
+(instancetype)Operation:(id)msg;
@end
