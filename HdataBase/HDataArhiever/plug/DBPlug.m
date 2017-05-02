//
//  DBPlug.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/28.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "DBPlug.h"

@implementation DBPlug
-(BOOL)isCanSaveToDB:(IvarInfomation *)info class:(Class)clazz{
    return YES;
}
-(id)valueForDB:(id)value clazz:(Class)clazz pro:(NSString *)name{
    return value;
}
@end
