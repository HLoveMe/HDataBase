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

/**字段保存   保存对象所有属性为字段*/
+(BOOL)saveObjectAllProperty:(NSObject<DBArhieverProtocol> *)obj;
/**字段保存   保存对象所有属性为字段*/
+(BOOL)saveObjscts:(NSArray<NSObject<DBArhieverProtocol> *> *)datas;

/**字段保存   提供ID 删除数据*/
+(BOOL)deleteObject:(NSString *)oneself class:(Class)clazz;
/**字段保存   提供ID 删除数据*/
+(BOOL)deleteObjectBy:(NSObject<DBArhieverProtocol>*)target;
/**字段保存   条件删除 删除数据*/
+(BOOL)deleteObject:(Class)class dic:(NSDictionary *)dic;
/**删除clazz所有数据*/
+(BOOL)deleteAllObjects:(Class)clazz;

/**字段保存   查找满足dic的对象 将其修改为obj*/
+(BOOL)updataObject:(NSObject<DBArhieverProtocol> *)obj Agrms:(NSDictionary<NSString*,NSString*>*)dic;
/**字段保存   查找满足oneself 修改为obj*/
+(BOOL)updateObject:(NSObject<DBArhieverProtocol> *)obj oneself:(NSString *)oneself;


/**字段保存  查询*/
+(NSArray *)objectsForAgrms:(NSDictionary<NSString*,NSString*>*)dic resultClazz:(Class)clazz;
//提供字段查找  只会返回得到结果的第一个
+(NSObject<DBArhieverProtocol> *)objectWithClass:(Class)clazz filed:(NSString *)key value:(NSString *)value;
+(NSArray *)objectsWithSQL:(NSString *)sql resultClass:(Class)clazz;
+(NSArray *)objectsWithClass:(Class)clazz;
+(NSArray *)objectsWithClass:(Class)clazz limit:(NSRange)rangle;



/**字段保存 增加字段*/
+(BOOL)addColumnWith:(Class)clazz filed:(NSString *)row;
/**删除表*/
+(BOOL)dropTable:(Class)clazz;
/**修改表名*/
+(BOOL)rename:(Class)oldClass useClass:(Class)newClass;

/**数据升级  将classA 升级为classB 还未测试*/
+(BOOL)dataUpdate:(Class)old new:(Class)newC dataChange:(id<DBArhieverProtocol>(^)(id value))handle deleteOld:(BOOL)flag;

@end
