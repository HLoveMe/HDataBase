//
//  DBPlug.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/28.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IvarInfomation;
@interface DBPlug : NSObject
//询问是否可以 保存数据库

/**
    在保存数据库期间   遍历属性时 会询问该属性是否可以保存数据库
    这将会影响 数据库字段 值得解析
 @param info IvarInfomation
 @param clazz Class
 @return BOOL
 */
-(BOOL)isCanSaveToDB:(IvarInfomation *)info class:(Class)clazz;

/**
 在读取数据库得到默认解析的值   你可以修改解析的值

 @param value 默认解析得到的值
 @param clazz 默认值得Class
 @return 你所希望的值
 */
-(id)valueForDB:(id)value clazz:(Class)clazz pro:(NSString *)name;
@end
