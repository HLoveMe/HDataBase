//
//  DataBaseConnect.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "DataBaseConnect.h"
#import "FMDB.h"
#import <objc/runtime.h>
#import "NSObject+Base.h"
#import "DBManager.h"
#import "DBBaseTargetProtocol.h"
#import "IvarInfomation.h"
#import "propertys.h"
@interface DataBaseConnect()

@end
@implementation DataBaseConnect
+(void)createTable:(Class)class{
    DBManager *manager = [DBManager shareDBManager];
    NSString*sql = [self sqlStringWith:FMDBCreate object:nil clazz:class];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        [database executeUpdate:sql];
        return YES;
    }];
}
+(BOOL)saveObjectAllProperty:(NSObject<DBArhieverProtocol> *)obj;{
    DBManager *manager = [DBManager shareDBManager];
    [self createTable:[obj class]];
    //防止一个 oneself对象多次保存
    if (NO){
        NSString *_sql = [NSString stringWithFormat:@"select count(*) from t_%@",[obj class]];
        if ([self objectsWithSQL:_sql resultClass:[obj class]].count == 1){
            return YES;
        }
    }
    
    //无记录继续保存
    __block BOOL flag = NO;
    __block NSString *sql = [self sqlStringWith:FMDBInsert object:obj clazz:[obj class]];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag = [database executeUpdate:sql];
        if (flag){
            //处理唯一标识 问题
            long lastid = [database lastInsertRowId];
            sql = [[NSString alloc]initWithFormat:@"select oneself from  t_%@  where rowid = '%ld'",[obj class],lastid];
            FMResultSet *set = [database executeQuery:sql];
            [set next];
            long ID = [[set objectForColumnName:@"oneself"] integerValue];
            [obj setOneself:ID];
        }
        return YES;
    }];
    return flag;
}
+(BOOL)saveObjscts:(NSArray<NSObject<DBArhieverProtocol> *> *)datas{
    DBManager *manager = [DBManager shareDBManager];
    __block BOOL flag = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        [database beginTransaction];
        [datas enumerateObjectsUsingBlock:^(NSObject<DBArhieverProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            flag = [self saveObjectAllProperty:obj];
        }];
        flag ? [database commit] : [database rollback];
        return YES;
    }];
    
    return flag;
}
/***删除数据*/
+(BOOL)deleteObject:(NSString *)oneself class:(Class)clazz;{
    return [self deleteObjectBy:[[clazz alloc]init]];
}
+(BOOL)deleteObjectBy:(NSObject<DBArhieverProtocol>*)target{
    DBManager *manager = [DBManager shareDBManager];
    NSString *sql = [self sqlStringWith:FMDBDelete object:target clazz:target.class];
    __block BOOL flag = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag=[database executeUpdate:sql];
        return YES;
    }];
    return flag;
}
+(BOOL)deleteObject:(Class)class dic:(NSDictionary *)dic{
    id obj = [[class alloc]init];
    objc_setAssociatedObject(obj, "dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    __block BOOL flag = NO;
    DBManager *manager = [DBManager shareDBManager];
    NSString *sql = [self sqlStringWith:FMDBDelete object:obj clazz:class];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag=[database executeUpdate:sql];
        return YES;
    }];
    return  flag;
}
+(BOOL)deleteAllObjects:(Class)clazz{
    __block BOOL flag = NO;
    DBManager *manager = [DBManager shareDBManager];
    NSString *sql = [NSString stringWithFormat:@"delete from t_%@ where '1' = '1'",clazz];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag=[database executeUpdate:sql];
        return YES;
    }];
    return  flag;
}
//  修改
/**字段保存   查找满足dic的对象 将其修改为obj*/
+(BOOL)updataObject:(NSObject<DBArhieverProtocol> *)obj Agrms:(NSDictionary<NSString*,NSString*>*)dic{
    objc_setAssociatedObject(obj, "dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *sql = [self sqlStringWith:FMDBUpdate object:obj clazz:obj.class];
    
    DBManager *manager = [DBManager shareDBManager];
    __block BOOL flag = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        [database beginTransaction];
        flag=[database executeUpdate:sql];
        flag ? [database commit] : [database rollback];
        return YES;
    }];
    return flag;
}
/**字段保存   查找满足oneself 修改为obj*/
+(BOOL)updateObject:(NSObject<DBArhieverProtocol> *)obj ID:(NSString *)oneself{
    return [self updataObject:obj Agrms:@{@"oneself":oneself}];
}
//查找
+(NSArray *)objectsForAgrms:(NSDictionary<NSString*,NSString*>*)dic resultClazz:(Class)clazz{
    id obj = [[clazz alloc]init];
    objc_setAssociatedObject(obj, @"dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString * sql =  [self sqlStringWith:FMDBSelect object:obj clazz:clazz];
    return [self objectsWithSQL:sql resultClass:clazz];
}
+(NSObject<DBArhieverProtocol> *)objectWithClass:(Class)clazz filed:(NSString *)key value:(NSString *)value{
    id obj = [[clazz alloc]init];
    objc_setAssociatedObject(obj, @"dic", @{key:value}, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString * sql =  [self sqlStringWith:FMDBSelect object:obj clazz:clazz];
    return [[self objectsWithSQL:sql resultClass:clazz close:NO] firstObject];
}
+(NSArray *)objectsWithSQL:(NSString *)sql resultClass:(Class)clazz close:(BOOL)close{
    DBManager *manager = [DBManager shareDBManager];
    NSMutableArray *objArray=[NSMutableArray array];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        FMResultSet *set=[database executeQuery:sql];
        __block id target ;
        while ([set next]) {
            target=[[clazz alloc]init];
            [target enumerateObjectsUsingBlock:^(IvarInfomation *info) {
                id temp_value = [info.property valueWithSet:^id<DBArhieverProtocol>(NSString *onself, __unsafe_unretained Class class) {
                    return  [self objectWithClass:class filed:@"oneself" value:onself];
                } set:set];
                if (temp_value)
                    [target setValue:temp_value forKey:info.property.name];
            }];
            [objArray addObject:target];
        }
        return close;
    }];
    
    return objArray;
}


+(NSArray *)objectsWithSQL:(NSString *)sql resultClass:(Class)clazz{
    return [self objectsWithSQL:sql resultClass:clazz close:YES];
}
+(NSArray *)objectsWithClass:(Class)clazz limit:(NSRange)rangle{
    NSString * sql =  [self sqlStringWith:FMDBSelect object:nil clazz:clazz];
    sql = [sql stringByAppendingFormat:@" limit %ld offset %ld",rangle.length,rangle.location];
    return [self objectsWithSQL:sql resultClass:clazz];
}
+(NSArray *)objectsWithClass:(Class)clazz{
    NSString * sql =  [self sqlStringWith:FMDBSelect object:nil clazz:clazz];
    return [self objectsWithSQL:sql resultClass:clazz];
}


+(BOOL)addColumnWith:(Class)clazz filed:(NSString *)row{
    DBManager *manager = [DBManager shareDBManager];
    NSString *table =[NSString stringWithFormat:@"t_%@",clazz];
    NSString *sql =[NSString stringWithFormat:@" alter table '%@' add '%@' text ",table,row];
    __block BOOL flag = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag = [database executeUpdate:sql];
        return YES;
    }];
    return flag;
}
+(BOOL)dropTable:(Class)clazz{
    NSString *sql=[self sqlStringWith:FMDBDrop  object:nil clazz:clazz];
    DBManager *manager = [DBManager shareDBManager];
    __block BOOL flag = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag = [database executeUpdate:sql];
        return YES;
    }];
    return flag;
}
+(BOOL)rename:(Class)oldClass useClass:(Class)newClass{
    
    NSString *sql=[[NSString alloc] initWithFormat:@"alter table t_%@ rename to t_%@",NSStringFromClass(oldClass),NSStringFromClass(newClass)];
    DBManager *manager = [DBManager shareDBManager];
    __block BOOL flag = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag = [database executeUpdate:sql];
        return YES;
    }];
    return flag;
}
+(BOOL)dataUpdate:(Class)old new:(Class)newC dataChange:(id<DBArhieverProtocol>(^)(id value))handle deleteOld:(BOOL)flag{
    
    FMDatabase *database = [[DBManager shareDBManager] dataBase];
    
    __block BOOL _flag = NO;
    
    if (handle == nil){return NO;}
    
    [self createTable:newC];
    
    [database beginTransaction];
    
    [[self objectsWithClass:old] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<DBArhieverProtocol> target = handle(obj);
        NSString *sql = [self sqlStringWith:FMDBInsert object:target clazz:[target class]];
        _flag = [database executeUpdate:sql];
    }];
    _flag ? [database commit] : [database rollback];
    if (flag && _flag){[self dropTable:old];}
    [database close];
    return _flag;
}


//为解决继承问题  增加参数clazz 表明你要处理的类型 （self super）
+(NSString *)sqlStringWith:(FMDBType)type object:(NSObject<DBArhieverProtocol> *)obj clazz:(Class)clazz{
    
    NSMutableString *sql=[NSMutableString string];
    switch (type) {
        case FMDBCreate:{
            [sql appendString:@"create table if not exists "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ ",clazz];
            [sql appendString:tableName];
            [sql appendString:[self option:clazz withType:FMDBCreate]];
            break;
        }
        case FMDBDrop:{
            [sql appendString:@"drop table if  exists "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ ",clazz];
            [sql appendString:tableName];
            break;
        }
        case FMDBInsert:{
            [sql appendString:@"insert into "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ ",clazz];
            [sql appendString:tableName];
            [sql appendString:[self option:obj.class withType:FMDBInsert]];
            [sql appendString:@" values "];
            NSArray *values = [self agrement:obj];
            [sql appendString:@"( "];
            [sql appendString:[values componentsJoinedByString:@","]];
            [sql appendString:@" )"];
            break;
        }
        case FMDBUpdate:{
            NSDictionary *dic = objc_getAssociatedObject(obj, "dic");
            objc_removeAssociatedObjects(obj);
            [sql appendString:@"update  "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ set ",clazz];
            [sql appendString:tableName];
            [sql appendString:[self propertyWithValue:obj withType:FMDBUpdate]];
            [sql appendString:@" where "];
            for (NSString *key in dic) {
                [sql appendFormat:@" %@ = '%@' and ",key,dic[key]];
            }
            sql = [sql substringToIndex:sql.length-5].mutableCopy;
            
            break;
        }
        case FMDBDelete:{
            [sql appendFormat:@" delete from t_%@ where '1' = '1' and ",clazz];
            NSDictionary *dic = objc_getAssociatedObject(obj, "dic");
            if (dic) {
                objc_removeAssociatedObjects(obj);
                [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [sql appendFormat:@" %@ = '%@' ",key,obj];
                    [sql appendFormat:@" and"];
                }];
                [sql replaceCharactersInRange:NSMakeRange(sql.length-4, 4) withString:@""];
            }else{
                sql = [@"dictionary is Null" mutableCopy];
            }
            break;
        }
        case FMDBSelect:{
            [sql appendFormat:@" select * from t_%@ where '1' = '1' and ",clazz];
            NSDictionary *dic =  objc_getAssociatedObject(obj, @"dic");
            objc_removeAssociatedObjects(obj);
            if (dic  != nil){
                for (NSString *key in dic) {
                    id value = dic[key];
                    [sql appendFormat:@" %@ = '%@' ",key,value];
                    [sql appendFormat:@" and"];
                }
            }
            [sql replaceCharactersInRange:NSMakeRange(sql.length-4, 4) withString:@""];
            break;
        }
        default:
            break;
    }
    return sql;
}
//(id primary key,name text ,price String)  选择性 去掉oneself
+(NSString *)option:(Class)clazz withType:(FMDBType)type{
    NSMutableString *sql=[NSMutableString stringWithString:@"("];
    NSMutableArray *array=[NSMutableArray array];
    [clazz enumerateIvar:^(NSString *name) {
        if (type==FMDBCreate)
            if ([name isEqualToString:@"oneself"]){
                [array addObject:[NSString stringWithFormat:@"%@ INTEGER PRIMARY KEY",name]];
            }else{
                [array addObject:[NSString stringWithFormat:@"%@ text",name]];
            }
            else{
                if (![name isEqualToString:@"oneself"]){
                    [array addObject:[NSString stringWithFormat:@"%@ ",name]];
                }
            }
    }];
    [sql appendString:[array componentsJoinedByString:@","]];
    [sql appendString:@" )"];
    
    return  sql;
}
//("zzh","66元",67) 去掉onself
+(NSArray *)agrement:(NSObject<DBArhieverProtocol> *)obj{
    
    NSMutableArray *array=[NSMutableArray array];
    
    [obj enumerateObjectsUsingBlock:^(IvarInfomation *info) {
        id temp_value;
        if(![info.property.name  isEqualToString:@"oneself"]){
            temp_value = [info.property getReadValue:^long(id<DBArhieverProtocol> obj) {
                if(obj){
                    [self saveObjectAllProperty:obj];
                    return [obj oneself];
                }
                return -1;
            } value:info.value];
            NSAssert(temp_value != nil, @"property getRead  not can  nil");
        }
        if(![info.property.name isEqualToString:@"oneself"]){
            temp_value=[@"'values'" stringByReplacingOccurrencesOfString:@"values" withString:[NSString stringWithFormat:@"%@",temp_value]];
            [array addObject:temp_value];
        }
    }];
    return array;
}
/**
 * name="zzh",price="66元",age=67 去掉oneself
 */
+(NSString *)propertyWithValue:(NSObject<DBArhieverProtocol> *)obj withType:(FMDBType)type{
    //(name ,price,age)
    NSString *option=[self option:obj.class withType:type];
    option=[option substringWithRange:NSMakeRange(1, option.length-2)];
    NSArray *arr1=[option componentsSeparatedByString:@","];
    //("zzh","66元",67)
    NSArray *arr2=[self agrement:obj];
    
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<arr1.count; i++) {
        NSString *key=arr1[i];
        NSString *valu=arr2[i];
        [array addObject:[NSString stringWithFormat:@"%@=%@",key,valu]];
    }
    NSString *str=[NSString stringWithFormat:@" %@ ",[array componentsJoinedByString:@","]];
    return str;
}


@end
