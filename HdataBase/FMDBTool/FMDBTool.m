//
//  FMDBTool.m
//  FMDB使用
//
//  Created by lx on 15/10/10.
//  Copyright (c) 2015年 朱子豪. All rights reserved.
//
#define HDataBasePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",[NSBundle mainBundle].infoDictionary[@"CFBundleName"]]]
#import "FMDBTool.h"
#import <objc/runtime.h>
static FMDatabase *dataBase;
@implementation FMDBTool
+(void)createDatabaseAndTableAndOpen:(NSObject *)obj{
    dataBase=[FMDatabase databaseWithPath:HDataBasePath];
    [dataBase open];
    [dataBase executeUpdate:[FMDBTool sqlStringWith:FMDBCreate object:obj]];
}
+(BOOL)saveObjectAllProperty:(NSObject *)obj{
    if (!dataBase) [FMDBTool createDatabaseAndTableAndOpen:obj];
    NSString *sql = [FMDBTool sqlStringWith:FMDBInsert object:obj];
    return [dataBase executeUpdate:sql];
}
+(NSArray *)objectForAgrms:(NSDictionary<NSString*,NSString*>*)dic clazz:(Class)clazz{
    id obj = [[clazz alloc]init];
    objc_setAssociatedObject(obj, @"dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString * sql =  [FMDBTool sqlStringWith:FMDBSelect object:obj];
     NSArray *array=[self objectsWithSQL:sql resultClass:clazz];
    return  array;
}

+(NSArray *)objectsWithSQL:(NSString *)sql resultClass:(Class)clazz{
    if (!dataBase) [FMDBTool createDatabaseAndTableAndOpen:[[clazz alloc]init]];
    id obj;
    NSMutableArray *objArray=[NSMutableArray array];
    FMResultSet *set=[dataBase executeQuery:sql];
    unsigned int count;
    objc_property_t *pros=class_copyPropertyList(clazz, &count);
    while ([set next]) {
        obj=[[clazz alloc]init];
        for (int i=0; i<count; i++) {
            objc_property_t pro=pros[i];
            NSString *proName=[NSString stringWithUTF8String:property_getName(pro)];
            id value=[set objectForColumnName:proName];
            if (value!=nil) {
                [obj setValue:value forKey:proName];
            }
        }
        [objArray addObject:obj];
    }
    return objArray;
}
+(NSArray *)ObjectsWithClass:(Class)clazz{
    NSString *sql=[@"select * from" stringByAppendingFormat:@" t_%@",NSStringFromClass(clazz)];
    return [self objectsWithSQL:sql resultClass:clazz];
}
+(BOOL)deleteObject:(NSObject *)obj{
    if (!dataBase) [FMDBTool createDatabaseAndTableAndOpen:obj];
    return  [dataBase executeUpdate:[FMDBTool sqlStringWith:FMDBDelete object:obj]];
}
+(BOOL)updataObject:(NSObject *)obj Agrms:(NSDictionary<NSString*,NSString*>*)dic{
    if (!dataBase) [FMDBTool createDatabaseAndTableAndOpen:obj];
    objc_setAssociatedObject(obj, "dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *sql = [FMDBTool sqlStringWith:FMDBUpdate object:obj];
    objc_removeAssociatedObjects(obj);
    return  [dataBase executeUpdate:sql];
}
+(BOOL)deleteAllObjects:(Class)clazz{
    if (!dataBase) [FMDBTool createDatabaseAndTableAndOpen:[[clazz alloc]init]];
    return [dataBase executeUpdate:[NSString stringWithFormat:@"delete from t_%@ where '1' = '1'",clazz]];
}

+(BOOL)dropTable:(Class)clazz{
    NSObject *obj=[[clazz alloc]init];
    if (!dataBase) [FMDBTool createDatabaseAndTableAndOpen:obj];
    NSString *sql=[FMDBTool sqlStringWith:FMDBDrop  object:obj];
    return  [dataBase executeUpdate:sql];
}

+(NSString *)sqlStringWith:(FMDBType)type object:(NSObject *)obj{
    NSMutableString *sql=[NSMutableString string];
    switch (type) {
        case FMDBCreate:{
            [sql appendString:@"create table if not exists "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ ",obj.class];
            [sql appendString:tableName];
            [sql appendString:[FMDBTool option:obj.class withType:FMDBCreate]];
            break;
        }
        case FMDBDrop:{
            [sql appendString:@"drop table if  exists "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ ",obj.class];
            [sql appendString:tableName];
            break;
        }
        case FMDBInsert:{
            [sql appendString:@"insert into "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ ",obj.class];
            [sql appendString:tableName];
            [sql appendString:[FMDBTool option:obj.class withType:FMDBInsert]];
            [sql appendString:@" values "];
            [sql appendString:[FMDBTool agrement:obj]];
            break;
        }
        case FMDBUpdate:{
            NSDictionary *dic = objc_getAssociatedObject(obj, "dic");
            [sql appendString:@"update  "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ set ",obj.class];
            [sql appendString:tableName];
            [sql appendString:[FMDBTool propertyWithValue:obj withType:FMDBUpdate]];
            [sql appendString:@" where "];
            for (NSString *key in dic) {
                [sql appendFormat:@" %@ = '%@' and ",key,dic[key]];
            }
            sql = [sql substringToIndex:sql.length-5].mutableCopy;
            [sql replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, sql.length)];
            [sql replaceOccurrencesOfString:@")" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, sql.length)];
            break;
        }
        case FMDBDelete:{
            [sql appendFormat:@" delete from t_%@ where '1' = '1' and ",obj.class];
            unsigned int num;
            objc_property_t *pros = class_copyPropertyList(obj.class, &num);
            for (int i=0; i<num; i++) {
                NSString *name = [NSString stringWithUTF8String:property_getName(pros[i])];
                id value = [obj valueForKey:name];
                if (value){
                    [sql appendFormat:@" %@ = '%@' ",name,value];
                    [sql appendFormat:@" and"];
                }
            }
            [sql replaceCharactersInRange:NSMakeRange(sql.length-4, 4) withString:@""];
            break;
        }
        case FMDBSelect:{
            [sql appendFormat:@" select * from t_%@ where '1' = '1' and ",obj.class];
            NSDictionary *dic =  objc_getAssociatedObject(obj, @"dic");
            for (NSString *key in dic) {
                id value = dic[key];
                [sql appendFormat:@" %@ = '%@' ",key,value];
                [sql appendFormat:@" and"];
            }
            [sql replaceCharactersInRange:NSMakeRange(sql.length-4, 4) withString:@""];
            break;
        }
        default:
            break;
    }
    return sql;
}
//(id primary key,name text ,price String)
+(NSString *)option:(Class)clazz withType:(FMDBType)type{
    NSMutableString *sql=[NSMutableString stringWithString:@"("];
    unsigned int count;
    objc_property_t *pros=class_copyPropertyList(clazz, &count);
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<count; i++) {
        objc_property_t pro=pros[i];
        NSString *proName=[NSString stringWithUTF8String:property_getName(pro)];
        if (type==FMDBCreate)
            [array addObject:[NSString stringWithFormat:@"%@ text",proName]];
        else
            [array addObject:[NSString stringWithFormat:@"%@ ",proName]];
        
    }
    [sql appendString:[array componentsJoinedByString:@","]];
    [sql appendString:@" )"];
    return  sql;
}
/**
 *("zzh","66元",67)
 */
+(NSString *)agrement:(NSObject *)obj{
    NSMutableString *agrement=[NSMutableString stringWithString:@"("];
    unsigned int count;
    objc_property_t *pros=class_copyPropertyList(obj.class, &count);
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<count; i++) {
        objc_property_t pro=pros[i];
        NSString *proName=[NSString stringWithUTF8String:property_getName(pro)];
        NSString *valu;
        valu=[obj valueForKey:proName];
        valu=[@"'values'" stringByReplacingOccurrencesOfString:@"values" withString:[NSString stringWithFormat:@"%@",valu]];
        [array addObject:valu];
        
    }
    [agrement appendString:[array componentsJoinedByString:@","]];
    [agrement appendString:@" )"];
    return agrement;
}
/**
 *(name="zzh",price="66元",age=67)
 */
+(NSString *)propertyWithValue:(NSObject *)obj withType:(FMDBType)type{
    //(name ,price,age)
    NSString *option=[FMDBTool option:obj.class withType:type];
    option=[option substringWithRange:NSMakeRange(1, option.length-2)];
    NSArray *arr1=[option componentsSeparatedByString:@","];
    //("zzh","66元",67)
    NSString *value=[FMDBTool agrement:obj];
    value=[value substringWithRange:NSMakeRange(1, value.length-2)];
    NSArray *arr2=[value componentsSeparatedByString:@","];
    
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<arr1.count; i++) {
        NSString *key=arr1[i];
        NSString *valu=arr2[i];
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,valu]];
    }
    NSString *str=[NSString stringWithFormat:@"(%@)",[array componentsJoinedByString:@","]];
    return str;
}



/////////////////////////////id主键  object 序列化对象   obj_flag 又一标识   //////////////////////////////////////
static     NSString *tableName;
+(void)createBaseTable:(Class)class{
    dataBase=[FMDatabase databaseWithPath:HDataBasePath];
    [dataBase open];
    [dataBase executeUpdate:[NSString stringWithFormat:@" CREATE TABLE if not exists %@ (id integer primary key,object BLOB ,obj_flag text)",tableName]];
}

+(BOOL)H_saveObject:(NSObject *)obj onlyFlag:(NSString *)flag{
    tableName=[NSString stringWithFormat:@"t_%@",NSStringFromClass(obj.class)];
    if (!dataBase) [FMDBTool createBaseTable:obj.class];
    NSData *data=[NSKeyedArchiver archivedDataWithRootObject:obj];
    NSString  *sql=[NSString stringWithFormat:@"insert into  %@ (object,obj_flag) values (?,?)",tableName];
    return  [dataBase executeUpdate:sql,data,flag];
    
}
+(BOOL)H_deleteObjectByFlag:(NSString *)obj_flag withClass:(Class)clazz{
    tableName=[NSString stringWithFormat:@"t_%@",NSStringFromClass(clazz)];
    if (!dataBase) [FMDBTool createBaseTable:clazz];
    [dataBase open];
    return  [dataBase executeUpdate:[NSString stringWithFormat:@"delete from %@ where obj_flag=%@ ",tableName,obj_flag]];
    
}
+(BOOL)H_deleteAllObjectwithClass:(Class)clazz{
    tableName=[NSString stringWithFormat:@"t_%@",NSStringFromClass(clazz)];
    if (!dataBase) [FMDBTool createBaseTable:clazz];
    NSString *sql=[NSString stringWithFormat:@"delete from %@ ",tableName];
    return [dataBase executeUpdate:sql];
}

+(NSArray *)H_ObjectsByClass:(Class)clazz{
    tableName=[NSString stringWithFormat:@"t_%@",NSStringFromClass(clazz)];
    if (!dataBase) [FMDBTool createBaseTable:clazz];
    id obj;
    NSString *sql=[NSString stringWithFormat:@"select  * from %@",tableName];
    NSMutableArray *objArray=[NSMutableArray array];
    FMResultSet *set=[dataBase executeQuery:sql];
    while (set.next) {
        NSData *readData=[set objectForColumnName:@"object"];
        obj=[NSKeyedUnarchiver unarchiveObjectWithData:readData];
        [objArray addObject:obj];
    }
    return objArray;
}
+(NSArray *)H_objects:(NSString *)sql Class:(Class)clazz{
    tableName=[NSString stringWithFormat:@"t_%@",NSStringFromClass(clazz)];
    if (!dataBase) [FMDBTool createBaseTable:clazz];
    id obj;
    NSMutableArray *objArray=[NSMutableArray array];
    FMResultSet *set=[dataBase executeQuery:sql];
    while (set.next) {
        NSData *readData=[set objectForColumnName:@"object"];
        obj=[NSKeyedUnarchiver unarchiveObjectWithData:readData];
        [objArray addObject:obj];
    }
    return objArray;
}
+(id)H_objectForFlag:(NSString *)flag withClazz:(Class)clazz{
    NSString *sql=[@"select * from" stringByAppendingFormat:@" t_%@",NSStringFromClass(clazz)];
    sql=[sql stringByAppendingFormat:@" where obj_flag ='%@'",flag];
    [FMDBTool createDatabaseAndTableAndOpen:[clazz new]];
    id obj;
    FMResultSet *result= [dataBase executeQuery:sql];
    if (result.next) {
        NSData *data=[result objectForColumnName:@"object"];
        obj=[NSKeyedUnarchiver unarchiveObjectWithData:data];
        return obj;
    }
    return nil;
}
@end
