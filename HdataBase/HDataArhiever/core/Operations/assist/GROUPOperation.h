//
//  GROUPOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "AssistOperation.h"

@interface GROUPOperation : AssistOperation
//msg 为 NSString(属性名称) or  PropertyCondition
//PropertyCondition  针对join
+(instancetype)Operation:(id)msg;
@end
