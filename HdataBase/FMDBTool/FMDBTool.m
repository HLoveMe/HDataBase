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
#import "NSObject+info.h"
#import "ivarInfomation.h"
static FMDatabase *dataBase;
@implementation FMDBTool
+(void)createDatabaseAndTableAndOpen:(NSObject *)obj{
    if (!dataBase) {
        dataBase=[FMDatabase databaseWithPath:HDataBasePath];
        [dataBase open];
    }
    if (obj){
        NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM sqlite_master WHERE type='table' AND name='t_%@'",obj.class];
         FMResultSet *set=[dataBase executeQuery:sql];
        [set next];
        if ([set intForColumnIndex:0]==1){
            return;
        }
        [dataBase executeUpdate:[FMDBTool sqlStringWith:FMDBCreate object:obj clazz:obj.class]];
    }
}

+(BOOL)saveObjectAllProperty:(NSObject *)obj{
    [FMDBTool createDatabaseAndTableAndOpen:obj];
    NSString *sql = [FMDBTool sqlStringWith:FMDBInsert object:obj clazz:obj.class];
    BOOL flag=[dataBase executeUpdate:sql];
    
    return flag;
}
+(BOOL)saveObjscts:(NSArray *)datas{
    [FMDBTool createDatabaseAndTableAndOpen:datas.firstObject];
    __block BOOL flag=1;
    [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL one=  [FMDBTool saveObjectAllProperty:obj];
        if (!one) {
            *stop=YES;
            flag=0;
        }
    }];
    return flag;
}
+(NSArray *)objectForAgrms:(NSDictionary<NSString*,NSString*>*)dic clazz:(Class)clazz{
    id obj = [[clazz alloc]init];
    objc_setAssociatedObject(obj, @"dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString * sql =  [FMDBTool sqlStringWith:FMDBSelect object:obj clazz:clazz];
    NSArray *array=[self objectsWithSQL:sql resultClass:clazz];
    return  array;
}

+(NSArray *)objectsWithSQL:(NSString *)sql resultClass:(Class)clazz{
    id obj=[[clazz alloc]init];
    [FMDBTool createDatabaseAndTableAndOpen:obj];
    NSMutableArray *objArray=[NSMutableArray array];
    FMResultSet *set=[dataBase executeQuery:sql];
    __block id value ;
    while ([set next]) {
        value=[[clazz alloc]init];
        
        [obj enumerateObjectsUsingBlock:^(ivarInfomation *info) {
            NSString *sqlValue = [set objectForColumnName:info.proName];
            if (sqlValue && ![sqlValue isEqualToString:@"(null)"]) {
                if (info.isArray) {
                    NSArray *result = [sqlValue componentsSeparatedByString:@"::"];
                    Class clazz = NSClassFromString(result[0]);
                    NSMutableArray *va =[NSMutableArray array];
                    if (clazz) {
                        NSArray *temp = [result[1] componentsSeparatedByString:@"-|-"];
                        [temp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            id t;
                            if([result[0] containsString:@"NS"]){
                                if ([result[0] containsString:@"String"]) {
                                    t=[NSString stringWithFormat:@"%@",obj];
                                }else{
                                    t = @([obj doubleValue]);
                                }
                            }else{
                                t = [NSObject objectWithDictionaryString:obj clazz:clazz];
                            }
                            [va addObject:t];
                        }];
                    }
                    
                    
                    [value setValue:va forKey:info.proName];
                }else if (!info.isFundation){
                    NSRange range = [sqlValue rangeOfString:@"::"];
                    NSString *result = [sqlValue substringFromIndex:range.location+2];
                    Class clazz = NSClassFromString(
                    [sqlValue substringToIndex:range.location]);
                    id res =[NSObject objectWithDictionaryString:result clazz:clazz];
                    [value setValue:res forKey:info.proName];
                }else{
                    id t;
                    if ([NSStringFromClass(info.valueClass) containsString:@"String"]) {
                        t=[set stringForColumn:info.proName];
                    }else{
                        t =@([set doubleForColumn:info.proName]);
                    }
                    [value setValue:t forKey:info.proName];
                }
            }
            
        }];
        [objArray addObject:value];
    }
    return objArray;
}
+(NSArray *)ObjectsWithClass:(Class)clazz{
    NSString *sql=[@"select * from" stringByAppendingFormat:@" t_%@",NSStringFromClass(clazz)];
    return [self objectsWithSQL:sql resultClass:clazz];
}
+(BOOL)deleteObject:(NSObject *)obj{
    [FMDBTool createDatabaseAndTableAndOpen:obj];
    return  [dataBase executeUpdate:[FMDBTool sqlStringWith:FMDBDelete object:obj clazz:obj.class]];
}
+(BOOL)deleteObject:(Class)class dic:(NSDictionary *)dic{
    id obj = [[class alloc]init];
    [FMDBTool createDatabaseAndTableAndOpen:obj];
    objc_setAssociatedObject(obj, "dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return  [dataBase executeUpdate:[FMDBTool sqlStringWith:FMDBDelete object:obj clazz:class]];
}
+(BOOL)updataObject:(NSObject *)obj Agrms:(NSDictionary<NSString*,NSString*>*)dic{
    [FMDBTool createDatabaseAndTableAndOpen:obj];
    objc_setAssociatedObject(obj, "dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *sql = [FMDBTool sqlStringWith:FMDBUpdate object:obj clazz:obj.class];
    objc_removeAssociatedObjects(obj);
    return  [dataBase executeUpdate:sql];
}
+(BOOL)deleteAllObjects:(Class)clazz{
    [FMDBTool createDatabaseAndTableAndOpen:[[clazz alloc]init]];
    return [dataBase executeUpdate:[NSString stringWithFormat:@"delete from t_%@ where '1' = '1'",clazz]];
}

+(BOOL)rename:(Class)oldClass useClass:(Class)newClass{
    [FMDBTool createDatabaseAndTableAndOpen:[[oldClass alloc]init]];
    return [dataBase executeUpdate:[[NSString alloc] initWithFormat:@"alter table t_%@ rename to t_%@",NSStringFromClass(oldClass),NSStringFromClass(newClass)]];
}
+(long long int )lastInsertRow{
    return [dataBase lastInsertRowId];
}
+(BOOL)addColumnWith:(Class)clazz filed:(NSString *)row{
    [FMDBTool createDatabaseAndTableAndOpen:nil];
    NSString *table =[NSString stringWithFormat:@"t_%@",clazz];
    NSString *sql =[NSString stringWithFormat:@" alter table '%@' add '%@' text ",table,row];
    BOOL flag=[dataBase executeUpdate:sql];
    return flag;
}
+(BOOL)dataUpdate:(Class)old new:(Class)newC deleteOld:(BOOL)flag2{
    id obj = [[newC alloc]init];
    [FMDBTool createDatabaseAndTableAndOpen:obj];
    FMResultSet *set=[dataBase executeQuery:[NSString stringWithFormat:@"select * from t_%@",old]];
    NSMutableArray *sqlArr = [NSMutableArray array];
    NSString *insert = [NSString stringWithFormat:@"insert into t_%@ ",newC];
    
    NSDictionary *par=@{};
    if ([newC respondsToSelector:@selector(dataMigrate)]){
        par = [newC performSelector:@selector(dataMigrate)];
    }
    while (set.next) {
        NSMutableArray *optArr =[NSMutableArray array];
        NSMutableArray *valueArr =[NSMutableArray array];
        [obj enumeratePropertyValue:^(NSString *proName, id value) {
            NSString * key=proName;
            NSString * oldkey = par[proName];
            if (oldkey) {key=oldkey;}
            id reavalue = [set stringForColumn:key];
            [valueArr addObject:[NSString stringWithFormat:@"'%@'",reavalue]];
            [optArr addObject:[NSString stringWithFormat:@"'%@'",proName]];
        }];
        NSString *one = [insert stringByAppendingFormat:@"(%@) values (%@)",[optArr componentsJoinedByString:@","],[valueArr componentsJoinedByString:@","]] ;
        [sqlArr addObject:one];
    }
    
    [dataBase beginTransaction];
    __block BOOL success=YES;
    [sqlArr enumerateObjectsUsingBlock:^(NSString * sql, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL flag = [dataBase executeUpdate:sql];
        *stop=!flag;
        success=flag;
    }];
    if (!success) {
        [dataBase rollback];
        return NO;
    }
    [dataBase commit];
    if (flag2){
        [FMDBTool dropTable:old];
    }
    return YES;
}
+(BOOL)dataUpdate:(Class)clazz{
    id obj=[[clazz alloc]init];
    [FMDBTool createDatabaseAndTableAndOpen:nil];
    
    NSString *createsql = [FMDBTool sqlStringWith:FMDBCreate object:obj clazz:[obj class]];
    NSString *tempTable = [NSString stringWithFormat:@"t_t_t_%@",clazz];
    createsql = [createsql stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"t_%@",clazz] withString:tempTable];
    [dataBase executeUpdate:createsql];
    
    FMResultSet *set=[dataBase executeQuery:[NSString stringWithFormat:@"select * from t_%@",clazz]];
    NSMutableArray *sqlArr = [NSMutableArray array];
    NSString *insert = [NSString stringWithFormat:@"insert into %@ ",tempTable];
    NSDictionary *par=@{};
    if ([clazz respondsToSelector:@selector(dataMigrate)]){
        par = [clazz performSelector:@selector(dataMigrate)];
    }
    while (set.next) {
        NSMutableArray *optArr =[NSMutableArray array];
        NSMutableArray *valueArr =[NSMutableArray array];
        [obj enumeratePropertyValue:^(NSString *proName, id value) {
            NSString * key=proName;
            NSString * oldkey = par[proName];
            if (oldkey) {key=oldkey;}
            id reavalue = [set stringForColumn:key];
            [valueArr addObject:[NSString stringWithFormat:@"'%@'",reavalue]];
            [optArr addObject:[NSString stringWithFormat:@"'%@'",proName]];
        }];
        NSString *one = [insert stringByAppendingFormat:@"(%@) values (%@)",[optArr componentsJoinedByString:@","],[valueArr componentsJoinedByString:@","]] ;
        [sqlArr addObject:one];
    }
    [dataBase beginTransaction];
    __block BOOL success=YES;
    [sqlArr enumerateObjectsUsingBlock:^(NSString * sql, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL flag = [dataBase executeUpdate:sql];
        *stop=!flag;
        success=flag;
    }];
    
    
    success=[FMDBTool dropTable:clazz];
    success=[dataBase executeUpdate:[[NSString alloc] initWithFormat:@"alter table %@ rename to t_%@",tempTable,NSStringFromClass(clazz)]];
    
    if (!success) {
        [dataBase rollback];
        return NO;
    }
    [dataBase commit];
    return YES;
}
+(BOOL)syncData:(Class)clazz{
    [FMDBTool createDatabaseAndTableAndOpen:nil];
    NSArray *array = [FMDBTool ObjectsWithClass:clazz];
    BOOL flag=1;
    [dataBase beginTransaction];
    flag = [FMDBTool deleteAllObjects:clazz];
    flag = [FMDBTool saveObjscts:array];
    if (!flag){
        [dataBase rollback];
        return NO;
    }
    [dataBase commit];
    return YES;
}

+(BOOL)dropTable:(Class)clazz{
    NSObject *obj=[[clazz alloc]init];
    [FMDBTool createDatabaseAndTableAndOpen:obj];
    NSString *sql=[FMDBTool sqlStringWith:FMDBDrop  object:obj clazz:clazz];
    return  [dataBase executeUpdate:sql];
}
//为解决继承问题  增加参数clazz 表明你要处理的类型 （self super）
+(NSString *)sqlStringWith:(FMDBType)type object:(NSObject *)obj clazz:(Class)clazz{
    NSMutableString *sql=[NSMutableString string];
    switch (type) {
        case FMDBCreate:{
            [sql appendString:@"create table if not exists "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ ",clazz];
            [sql appendString:tableName];
            [sql appendString:[FMDBTool option:obj.class withType:FMDBCreate]];
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
            [sql appendString:[FMDBTool option:obj.class withType:FMDBInsert]];
            [sql appendString:@" values "];
            [sql appendString:[FMDBTool agrement:obj]];
            break;
        }
        case FMDBUpdate:{
            NSDictionary *dic = objc_getAssociatedObject(obj, "dic");
            objc_removeAssociatedObjects(obj);
            [sql appendString:@"update  "];
            NSString *tableName=[NSString stringWithFormat:@"t_%@ set ",clazz];
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
            [sql appendFormat:@" delete from t_%@ where '1' = '1' and ",clazz];
            NSDictionary *dic = objc_getAssociatedObject(obj, "dic");
            if (dic) {
                objc_removeAssociatedObjects(obj);
                [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [sql appendFormat:@" %@ = '%@' ",key,obj];
                    [sql appendFormat:@" and"];
                }];
            }else{
                unsigned int num;
                objc_property_t *pros = class_copyPropertyList(clazz, &num);
                for (int i=0; i<num; i++) {
                    NSString *name = [NSString stringWithUTF8String:property_getName(pros[i])];
                    id value = [obj valueForKey:name];
                    if (value){
                        [sql appendFormat:@" %@ = '%@' ",name,value];
                        [sql appendFormat:@" and"];
                    }
                }
            }
            [sql replaceCharactersInRange:NSMakeRange(sql.length-4, 4) withString:@""];
            break;
        }
        case FMDBSelect:{
            [sql appendFormat:@" select * from t_%@ where '1' = '1' and ",clazz];
            NSDictionary *dic =  objc_getAssociatedObject(obj, @"dic");
            objc_removeAssociatedObjects(obj);
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
    NSMutableArray *array=[NSMutableArray array];
    [[[clazz alloc] init] enumeratePropertyValue:^(NSString *proName, id proValue) {
        if (type==FMDBCreate)
            [array addObject:[NSString stringWithFormat:@"%@ text",proName]];
        else{
            [array addObject:[NSString stringWithFormat:@"%@ ",proName]];
        }
    }];
    [sql appendString:[array componentsJoinedByString:@","]];
    [sql appendString:@" )"];
    
    return  sql;
}
/**
 *("zzh","66元",67)
 */
+(NSString *)agrement:(NSObject *)obj{
    NSMutableString *agrement=[NSMutableString stringWithString:@"("];
    NSMutableArray *array=[NSMutableArray array];
    
    [obj enumerateObjectsUsingBlock:^(ivarInfomation *info) {
        id valu=@"null";
        if(info.isArray){
            if (info.proValue) {
                NSArray * temp = (NSArray *)info.proValue;
                if(!info.arrIsFundation){
                    NSMutableArray *nums = [NSMutableArray array];
                    [temp enumerateObjectsUsingBlock:^(id  _Nonnull res, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *a = [res toString];
                        [nums addObject:a];
                    }];
                    valu=[nums componentsJoinedByString:@"-|-"];
                }else{
                    valu=[temp componentsJoinedByString:@"-|-"];
                }
                valu = [@"" stringByAppendingFormat:@"%@::%@",info.arrClazz,valu];
            }
        }else if (!info.isFundation) {
            if (info.proValue){
                NSString *a = [info.proValue toString];
                valu=[NSString stringWithFormat:@"%@::%@",info.valueClass,a];
            }
        }else{
            valu=info.proValue;
        }
        valu=[@"'values'" stringByReplacingOccurrencesOfString:@"values" withString:[NSString stringWithFormat:@"%@",valu]];
        [array addObject:valu];
    }];
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
+(void)closeDataBase{
    if (dataBase) {
        [dataBase close];
        dataBase=nil;
    }
}
@end
