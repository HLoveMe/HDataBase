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
//更改表名 但是还是使用t_XXX作为操作数据库的表名
+(BOOL)rename:(Class)oldClass useClass:(Class)newClass;
//最后插进去的rowid
+(long long int )lastInsertRow;
//增加行 
+(BOOL)addColumnWith:(Class)clazz filed:(NSString *)name;


/**
 数据表迁移  newC实现+(NSDictionary *)dataMigrate  是否删除之前表 YES
     
        +(NSDictionary *)dataMigrate{
            返回属性名对应关系
            return @{@"newID":@"oldID"
        }
 说明:
    如果数据本身处在关联关系
        例: Person 有一个属性为 Car 对象
    如果在更新Person对应的表后
        如果也修改了Car 属性，那么Car就要实现+(NSDictionary *)dataMigrate，建议调用@selector(syncData:)
 
        }
 */
+(BOOL)dataUpdate:(Class)old new:(Class)newC  deleteOld:(BOOL)flag;
/**数据表升级  实现+(NSDictionary *)dataMigrate*/
+(BOOL)dataUpdate:(Class)clazz;

/**更新表 并且也更新关联对象 建议调用以保证 已保存的数据也更新*/
+(BOOL)syncData:(Class)clazz;

@end



