//
//  FMDBTool.h
//  FMDB使用
//
//  Created by lx on 15/10/10.
//  Copyright (c) 2015年 朱子豪. All rights reserved.
//
/**
    对FMDB数据库操作的简化
    1:内部会根据存储对象的Class 自动创建t_className的表
    2:满足 类的继承特性
    3:对系统提供的类 支持 NSString NSNumber(i l f d 等) NSArray(存储的为自定义对象)
 */

#import <Foundation/Foundation.h>
#import "FMDB.h"
typedef enum {
    FMDBCreate,//创建表
    FMDBDrop, //删除表
    
    FMDBInsert,
    FMDBUpdate,
    FMDBDelete,
    FMDBSelect
}FMDBType;

@interface FMDBTool : NSObject

/**字段保存   保存对象所有属性为字段*/
+(BOOL)saveObjectAllProperty:(NSObject *)obj;
+(BOOL)saveObjscts:(NSArray *)datas;
/**字段保存   删除该对象  */
+(BOOL)deleteObject:(NSObject *)obj;

+(BOOL)deleteObject:(Class)class dic:(NSDictionary *)dic;

/**字段保存    更新该对象  满足条件的数据都会被更新*/
+(BOOL)updataObject:(NSObject *)obj Agrms:(NSDictionary<NSString*,NSString*>*)dic;

 /**字段保存   给定指定条件 满足条件的都会被查询出来*/
+(NSArray *)objectForAgrms:(NSDictionary<NSString*,NSString*>*)dic clazz:(Class)clazz;

/**字段保存   给定查找SQl查找数据  返回模型数组*/
+(NSArray *)objectsWithSQL:(NSString *)sql resultClass:(Class)clazz;

/** 字段保存  获取所有数据*/
+(NSArray *)ObjectsWithClass:(Class)clazz;



/////////////////////////////////////
 /**关闭数据库连接*/
+(void)closeDataBase;
 /**删除表*/
+(BOOL)dropTable:(Class)clazz;
 /**删除clazz所有数据*/
+(BOOL)deleteAllObjects:(Class)clazz;
//更改表名
+(BOOL)rename:(Class)oldClass useClass:(Class)newClass;
//最后插进去的rowid
+(long long int )lastInsertRow;
//增加行 
+(BOOL)addColumnWith:(Class)clazz filed:(NSString *)name;
/////////////////////////////////////



/**
 *  对象必须实现NSCoding协议
 */

/**整个对象序列化   再保存到数据库中  必须提供一个唯一标示*/
+(BOOL)H_saveObject:(NSObject *)obj onlyFlag:(NSString *)flagValue;
+(BOOL)H_saveObjscts:(NSArray *)datas onlyFlag:(NSString *)flagValue;
 /**整个对象序列化  删除所有数据*/
+(BOOL)H_deleteAllObjectwithClass:(Class)clazz;

/** 整个对象序列化  删除数据*/
+(BOOL)H_deleteObjectByFlag:(NSString *)obj_flag withClass:(Class)clazz;

 /**整个对象序列化   给定唯一标示得到某个Model*/
+(id)H_objectForFlag:(NSString *)flag withClazz:(Class)clazz;

 /** 整个对象序列化  获取所有数据*/
+(NSArray *)H_ObjectsByClass:(Class)clazz;

/**整个对象序列化    给定查找SQl查找数据  返回模型数组*/
+(NSArray *)H_objects:(NSString *)sql Class:(Class)clazz;
@end



