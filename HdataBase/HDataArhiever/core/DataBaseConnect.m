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
#import "NSObject+SEL.h"
#import "DBManager.h"
#import "DBBaseTargetProtocol.h"
#import "IvarInfomation.h"
#import "propertys.h"
#import "DBPlugBox.h"
#import "DBPlug.h"
#import "PrepareStatus.h"
typedef enum {
    FMDBCreate,//创建表
    FMDBDrop, //删除表
    
    FMDBInsert,
    FMDBUpdate,
    FMDBDelete,
    FMDBSelect
}FMDBType;
@interface DataBaseConnect()
@end
@implementation DataBaseConnect
+(NSString *)tableName:(Class)clazz{
    return [NSString stringWithFormat:@"t_%@",clazz];
}
+(void)createTable:(Class)class{
    DBManager *manager = [DBManager shareDBManager];
    NSAssert([class isBaseTarget], @"your class should implementation DBArhieverProtocol or extends DBBaseTarget");
    NSString*sql = [self sqlStringWith:FMDBCreate object:nil clazz:class];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        [database executeUpdate:sql];
        return YES;
    }];
}
+(BOOL)saveObjectAllProperty:(NSObject<DBArhieverProtocol> *)obj;{
    DBManager *manager = [DBManager shareDBManager];
    [self createTable:[obj class]];
    //防止一个 oneself/ID 对象多次保存
    __block BOOL isExits = NO;
    __block BOOL flag = NO;
    SEL asel = @selector(uniqueness);
    NSString *IDName = @"onnself";
    NSString *value = [NSString stringWithFormat:@"%ld",obj.oneself];
    if([obj respondsToSelector:asel]){
        @try {
            IDName = [obj performSelector:asel];
            value = [obj valueForKey:IDName];
        } @catch (NSException *exception) {
            NSLog(@"SEL uniqueness return value Error");
            return  NO;
        }
    }
    NSString *_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = %@",[self tableName:[obj class]],IDName,value];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        FMResultSet *set = [database executeQuery:_sql];
        [set next];
        int count = [set intForColumnIndex:0];
        if (count == 1){
            flag = [self updateObject:obj oneself:[NSString stringWithFormat:@"%@",value]];
            isExits = YES;
        }else if(count > 1){
            NSLog(@"SEL uniqueness 指定的属性不能唯一标示");
        }
        return YES;
    }];
    
    if(isExits){
        return flag;
    }
    
    //无记录继续保存
    
    __block NSString *sql = [self sqlStringWith:FMDBInsert object:obj clazz:[obj class]];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag = [database executeUpdate:sql];
        if (flag){
            //处理唯一标识 问题
            long lastid = [database lastInsertRowId];
            sql = [[NSString alloc]initWithFormat:@"select oneself from  %@  where rowid = '%ld'",[self tableName:[obj class]],lastid];
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
    __block BOOL isBeginTran = NO;
    [manager connectDatabaseOperationNoClose:^(FMDatabase *database) {
        if(![database inTransaction]){
            [database beginTransaction];
            isBeginTran = YES;
        }
        [datas enumerateObjectsUsingBlock:^(NSObject<DBArhieverProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            flag = [self saveObjectAllProperty:obj];
            if(!flag)
                *stop = !flag;
        }];
        if(isBeginTran)
            flag ? [database commit] : [database rollback];
    }];
    
    return flag;
}

+(BOOL)deleteObject:(Class)class Argms:(NSDictionary<NSString *,NSString*> *)dic{
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
    __block BOOL isBeginTran = NO;
    DBManager *manager = [DBManager shareDBManager];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where '1' = '1'",[self tableName:clazz]];
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        if(![database inTransaction]){
            [database beginTransaction];
            isBeginTran = YES;
        }
        flag=[database executeUpdate:sql];
        if(isBeginTran)
            flag ? [database commit] : [database rollback];
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
    __block BOOL isBeginTran = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        if(![database inTransaction]){
            [database beginTransaction];
            isBeginTran = YES;
        }
        flag=[database executeUpdate:sql];
        if(isBeginTran)
            flag ? [database commit] : [database rollback];
        return YES;
    }];
    return flag;
}
/**字段保存   查找满足oneself 修改为obj*/
+(BOOL)updateObject:(NSObject<DBArhieverProtocol> *)obj oneself:(NSString *)oneself{
    SEL asel = @selector(uniqueness);
    NSString *name = @"oneself";
    if([obj respondsToSelector:asel]){
        NSString *_name = [obj performSelector:asel];
        if(_name)
            name = _name;
    }
    return [self updataObject:obj Agrms:@{name:oneself}];
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
        DBPlugBox *box = [DBPlugBox shareBox];
        DBPlug *plug = [box plugFor:clazz];
        while ([set next]) {
            target=[[clazz alloc]init];
            [target enumerateObjectsUsingBlock:^(IvarInfomation *info) {
                id temp_value = [info.property valueWithSet:^id<DBArhieverProtocol>(NSString *onself, __unsafe_unretained Class class) {
                    return  [self objectWithClass:class filed:@"oneself" value:onself];
                } set:set sqlV:[set stringForColumn:info.property.name] class:info.property.proClass];
                if(plug)
                    temp_value = [plug valueForDB:temp_value clazz:clazz pro:info.property.name];
                if (temp_value && ![info.property isKindOfClass:[SELProperty class]])
                    [target setValue:temp_value forKey:info.property.name];
                else if(temp_value && [info.property isKindOfClass:[SELProperty class]]){
                    NSMutableDictionary *sel = [target addSelDictionary];
                    sel[info.property.name] = temp_value;
                }
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
    NSString *table = [self tableName:clazz];
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
    
    NSString *sql=[[NSString alloc] initWithFormat:@"alter table %@ rename to %@",[self tableName:oldClass],[self tableName:newClass]];
    DBManager *manager = [DBManager shareDBManager];
    __block BOOL flag = NO;
    [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
        flag = [database executeUpdate:sql];
        return YES;
    }];
    return flag;
}

+(NSString *)sqlStringWith:(FMDBType)type object:(NSObject<DBArhieverProtocol> *)obj clazz:(Class)clazz{
    
    NSMutableString *sql=[NSMutableString string];
    switch (type) {
        case FMDBCreate:{
            [sql appendString:@"create table if not exists "];
            NSString *tableName=[NSString stringWithFormat:@"%@ ",[self tableName:clazz]];
            [sql appendString:tableName];
            [sql appendString:[self option:clazz withType:FMDBCreate]];
            break;
        }
        case FMDBDrop:{
            [sql appendString:@"drop table if  exists "];
            NSString *tableName=[NSString stringWithFormat:@"%@ ",[self tableName:clazz]];
            [sql appendString:tableName];
            break;
        }
        case FMDBInsert:{
            [sql appendString:@"insert into "];
            NSString *tableName=[NSString stringWithFormat:@"%@ ",[self tableName:clazz]];
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
            NSString *tableName=[NSString stringWithFormat:@"%@ set ",[self tableName:clazz]];
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
            [sql appendFormat:@" delete from %@ where '1' = '1' and ",[self tableName:clazz]];
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
            [sql appendFormat:@"select * from %@ where '1' = '1' and ",[self tableName:clazz]];
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
    [clazz enumerateIvar2:^(NSString *name, NSString *vtype) {
        if (type==FMDBCreate){
            if ([name isEqualToString:@"oneself"]){
                [array addObject:[NSString stringWithFormat:@"%@ INTEGER PRIMARY KEY",name]];
            }else{
                [array addObject:[NSString stringWithFormat:@"%@ %@",name,[self dbType:vtype]]];
            }
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
    DBPlugBox *box = [DBPlugBox shareBox];
    DBPlug *plug = [box plugFor:[obj class]];
    [obj enumerateObjectsUsingBlock:^(IvarInfomation *info) {
        NSString *temp_value;
        if(![info.property.name  isEqualToString:@"oneself"]){
            temp_value = [info.property getReadValue:^long(id<DBArhieverProtocol> obj) {
                if(obj){
                    [self saveObjectAllProperty:obj];
                    return [obj oneself];
                }
                return -1;
            } value:info.value];
            if(plug)
                temp_value = [plug valueForDB:temp_value clazz:[obj class] pro:info.property.name];
            NSAssert(temp_value != nil, @"property getRead method return not can  nil");
        }
        if(![info.property.name isEqualToString:@"oneself"]){
            temp_value=[@"'values'" stringByReplacingOccurrencesOfString:@"values" withString:temp_value];
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
// 由数据类型转为 数据库保存的类型
+(NSString *)dbType:(NSString *)type{
    //INTEGER  FLOAT  DOUBLE BOOLEAN TEXT DATE
    if([type isEqualToString:@"B"]){
        return @"BOOLEAN";
    }else if([@"fdD" containsString:type]){
        return @"DOUBLE";
    }else if([@"sSiIqQL" containsString:type]){
        return @"INTEGER";
    }else{
        return @"TEXT";
    }
}
@end


@implementation DataBaseConnect (updateBase)

+(BOOL)dataUpdate:(Class)old new:(Class)newC dataChange:(id<DBArhieverProtocol>(^)(id value))handle deleteOld:(BOOL)flag{
    if([[old description] isEqualToString:[newC description]]){return NO;}
    if(!handle)return NO;
    __block BOOL _flag = NO;
    DBManager *manager =[DBManager shareDBManager];
    
    [manager connectDatabaseOperationNoClose:^(FMDatabase *database) {
        [manager dataUpdate:^BOOL(FMDatabase *database) {
            @try {
                NSArray *models = [self objectsWithClass:old];
                
                [self createTable:newC];
                
                [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    id target = handle(obj);
                    
                    NSString *sql = [self sqlStringWith:FMDBInsert object:target clazz:newC];
                    
                    _flag = [database executeUpdate:sql];
                    *stop = !_flag;
                }];
                if(flag)
                    _flag = [self dropTable:old];
            } @catch (NSException *exception) {
                _flag = NO;
                return NO;
            }
            return _flag;
        }];
    }];
    return _flag;
}
+(BOOL)update:(Class)clazz dataChange:(id<DBArhieverProtocol>(^)(id value))handle{
    if(!handle)return NO;
    __block BOOL _flag = NO;
    DBManager *manager =[DBManager shareDBManager];
    
    [manager connectDatabaseOperationNoClose:^(FMDatabase *database) {
        [manager dataUpdate:^BOOL(FMDatabase *database) {
            @try {
                NSArray *models = [self objectsWithClass:clazz];
                
                NSString *dropsql=[self sqlStringWith:FMDBDrop  object:nil clazz:clazz];
                _flag = [database executeUpdate:dropsql];
                if(!_flag)
                    return NO;
                [self createTable:clazz];
                
                [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    id target = handle(obj);
                    //这一步牵扯到数据的插入 / 更新
                    NSString *sql = [self sqlStringWith:FMDBInsert object:target clazz:[target class]];
                    _flag = [database executeUpdate:sql];
                    *stop = !_flag;
                }];
            } @catch (NSException *exception) {
                _flag = NO;
                return NO;
            }
            return _flag;
        }];
    }];
    
    return _flag;
}
+(BOOL)update2:(Class)clazz dataChange:(id<DBArhieverProtocol>(^)(NSDictionary *value))handle{
    if(!handle)return NO;
    __block BOOL _flag = NO;
    DBManager *manager =[DBManager shareDBManager];
    [manager connectDatabaseOperationNoClose:^(FMDatabase *database) {
        [manager dataUpdate:^BOOL(FMDatabase *database) {
            NSString * sql =  [self sqlStringWith:FMDBSelect object:nil clazz:clazz];
            FMResultSet *set = [database executeQuery:sql];
            NSMutableArray<id<DBArhieverProtocol>> *models = [NSMutableArray array];
            while ([set next]) {
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                int count = [set columnCount];
                for (int i=0; i<count; i++) {
                    NSString *value = [set stringForColumnIndex:i];
                    if([Property dataBaseIsValue:value]){
                        NSString *name = [set columnNameForIndex:i];
                        id result  = [PropertyFactory valueForString:value block:^id<DBArhieverProtocol>(NSString *onself, __unsafe_unretained Class class) {
                            return [self objectWithClass:class filed:@"oneself" value:onself];;
                        }];
                        if(result)
                            info[name] = result;
                        else
                            info[name] = [NSNull null];
                    }
                }
                id value = handle(info);
                if(value)
                    [models addObject:value];
            }
            _flag = [self dropTable:clazz];
            if(!_flag)
                return _flag;
            [models enumerateObjectsUsingBlock:^(id<DBArhieverProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                _flag = [self saveObjectAllProperty:obj];
            }];
            return _flag;
        }];
    }];
    return _flag;
}
@end

@implementation DataBaseConnect (operation)
+(PrepareStatus *)objectsForAgrms:(NSDictionary<NSString*,NSString*>*)dic target:(Class)clazz{
    id obj = [[clazz alloc]init];
    objc_setAssociatedObject(obj, @"dic", dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString * sql =  [self sqlStringWith:FMDBSelect object:obj clazz:clazz];
    PrepareStatus *status = [[PrepareStatus alloc]init];
    status.sql = [sql mutableCopy];
    status.valueC = clazz;
    return status;
}
+(PrepareStatus *)objectsWithTarget:(Class)clazz{
    NSString * sql =  [self sqlStringWith:FMDBSelect object:nil clazz:clazz];
    PrepareStatus *status = [[PrepareStatus alloc]init];
    status.sql = [sql mutableCopy];
    status.valueC = clazz;
    return status;
}
+(PrepareStatus *(^)(Class clazz))prepare{
    return ^PrepareStatus *(Class clazz){
        return [DataBaseConnect objectsWithTarget:clazz];
    };
}
+(PrepareStatus *(^)(Class clazz,NSDictionary *args))prepare2{
    return ^PrepareStatus *(Class clazz,NSDictionary *args){
        return [DataBaseConnect objectsForAgrms:args target:clazz];
    };
}
@end
