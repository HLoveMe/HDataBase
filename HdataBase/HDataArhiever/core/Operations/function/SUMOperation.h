//
//  SUMOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "FUNCOperation.h"

@interface SUMOperation : FUNCOperation
//求和
//msg 为 NSString(属性名称) or  PropertyCondition
//PropertyCondition  针对join
+(instancetype)Operation:(id)msg;
@end
