//
//  DataBaseConnect.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBBaseTargetProtocol.h"
typedef enum {
    FMDBCreate,//创建表
    FMDBDrop, //删除表
    
    FMDBInsert,
    FMDBUpdate,
    FMDBDelete,
    FMDBSelect
}FMDBType;

@interface DataBaseConnect : NSObject


/**
 字段保存   保存对象所有属性为字段

 @param obj 对象 如果你的模型有唯一标识  那么会先验证是否存在 存在它将是属于Update操作
 @return 是否成功
 */
+(BOOL)saveObjectAllProperty:(NSObject<DBArhieverProtocol> *)obj;

/**
 字段保存   保存对象所有属性为字段   《开启事务》

 @param datas 模型数组
 @return 是否YES
 */
+(BOOL)saveObjscts:(NSArray<NSObject<DBArhieverProtocol> *> *)datas;

/**
 字段保存   条件删除 删除数据

 @param class class
 @param dic 条件
 @return 是否删除
 */
+(BOOL)deleteObject:(Class)class Argms:(NSDictionary<NSString *,NSString*> *)dic;

/**
 删除表中所有数据  不删除关联对象  《开启事务》

 @param clazz  表
 @return 是否成功
 */
+(BOOL)deleteAllObjects:(Class)clazz;


/**
 字段保存   查找满足dic的对象 将其修改为obj 《开启事务》
 所有满足条件的对象都会被修改
 @param obj
 @param dic 条件
 @return 是否成功
 */
+(BOOL)updataObject:(NSObject<DBArhieverProtocol> *)obj Agrms:(NSDictionary<NSString*,NSString*>*)dic;

/**
 提供唯一性属性的值 更新数据   《开启事务》

 @param obj 满足条件的数据 修改为obj
 @param isaValue 唯一性的值
 @return 是否成功
 */
+(BOOL)updateObject:(NSObject<DBArhieverProtocol> *)obj oneself:(NSString *)isaValue;



/**
 满足条件的查询

 @param dic 条件
 @param clazz 表
 @return 结果
 */
+(NSArray *)objectsForAgrms:(NSDictionary<NSString*,NSString*>*)dic resultClazz:(Class)clazz;

/**
 提供某个数据查找 只会返回得到结果的第一个

 @param clazz 表
 @param key   建
 @param value 值
 @return obj
 */
+(NSObject<DBArhieverProtocol> *)objectWithClass:(Class)clazz filed:(NSString *)key value:(NSString *)value;
+(NSArray *)objectsWithSQL:(NSString *)sql resultClass:(Class)clazz;
+(NSArray *)objectsWithClass:(Class)clazz;
+(NSArray *)objectsWithClass:(Class)clazz limit:(NSRange)rangle;


/**
 字段保存 增加字段

 @param clazz 表
 @param row 字典
 @return success
 */
+(BOOL)addColumnWith:(Class)clazz filed:(NSString *)row;

/**
 删除表

 @param clazz 表
 @return success
 */
+(BOOL)dropTable:(Class)clazz;

/**
 修改表
 @param oldClass old
 @param newClass new 表
 @return success
 */
+(BOOL)rename:(Class)oldClass useClass:(Class)newClass;

/**
 更新数据库 更新表为新的表 内部已经做了
 更新失败机制如果失败  就会会退到之前数据
 
 @param old 旧的Class
 @param newC 新的Class
 @param handle 处理器
 @param flag 是否删除旧表
 @return 是否成功
 */
+(BOOL)dataUpdate:(Class)old new:(Class)newC dataChange:(id<DBArhieverProtocol>(^)(id value))handle deleteOld:(BOOL)flag;

/**
 更新 当前表数据
 更新失败机制如果失败  就会会退到之前数据
 
 @param clazz 当前class
 @param handle 处理器
 @return 是否成功
 */
+(BOOL)update:(Class)clazz dataChange:(id<DBArhieverProtocol>(^)(id value))handle;
@end
