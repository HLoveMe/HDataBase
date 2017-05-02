//
//  generalProperty.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "Property.h"
//用于处理系统可保存类型
//NSString NSNumber  NSURL NSDate
@interface GeneralProperty : Property
+(id)valueWithstr:(NSString *)str class:(Class)class;
@end
