//
//  ClassManager.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/27.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassManager : NSObject
//可以保存class

+(BOOL)isEnCode:(id)value;

//由于字符串 或者 数组 class  可能为 __NSCFString, __NSArrayM __NSTaggedDate ....等等
//这里统一 class
+(Class)valueClass:(id)value;

@end
