//
//  PrepareStatus.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "PrepareStatus.h"
#import "DBOperation.h"
#import "DataBaseConnect.h"
#import "DBManager.h"
#import "ValueOperation.h"
#import "PrerequisiteOperation.h"
#import "GROUPOperation.h"
#import "ORDEROperation.h"
#import "LimitOperation.h"
#import "FUNCOperation.h"
#import "JoinOperation.h"
#import "FMDB.h"
#import "PropertyFactory.h"
#import "PropertyCondition.h"
#import "NSObject+Base.h"
@interface PrepareStatus()
//所有
@property(nonatomic,strong)NSMutableArray<DBOperation *> *operas;
//only one  select */(name,age..)
@property(nonatomic,strong)NSMutableArray<DBOperation *> *valueOps;
// 查找条件   where name Like xx or/and age >= 18
@property(nonatomic,strong)NSMutableArray<DBOperation *> *prepres;

// 辅助    limit 排序 分组
@property(nonatomic,strong)NSMutableArray<DBOperation *> *assists;

//jons
@property(nonatomic,strong)JoinOperation *joins;
//函数 MAX
@property(nonatomic,strong)NSMutableArray<DBOperation *> *funcs;

@property(nonatomic,assign)BOOL ValueArry;

@property(nonatomic,assign)BOOL hasParser;
@end
//static Class clazz;
@implementation PrepareStatus
//+(Class)valueC{
//    return clazz;
//}
-(void)setValueC:(Class)valueC{
    _valueC = valueC;
//    clazz = valueC;
}
-(instancetype)init{
    if(self= [super init]){
        self.ValueArry = YES;
    }
    return self;
}
-(NSMutableArray *)valueOps{
    if (nil==_valueOps) {
        _valueOps=[NSMutableArray array];
    }
    return _valueOps;
}
-(NSMutableArray<DBOperation *> *)prepres{
    if(_prepres==nil){
        _prepres = [NSMutableArray array];
    }
    return _prepres;
}
-(NSMutableArray<DBOperation *> *)assists{
    if(_assists==nil){
        _assists = [NSMutableArray arrayWithArray:@[@"",@"",@""]];
    }
    return _assists;
}
-(NSMutableArray *)funcs{
    if (nil==_funcs) {
        _funcs=[NSMutableArray array];
    }
    return _funcs;
}
-(NSMutableArray<DBOperation *> *)operas{
    if(_operas==nil){
        _operas = [NSMutableArray array];
    }
    return _operas;
}
-(NSArray *)operations{
    return self.operas;
}
-(PrepareStatus *)addOperation:(DBOperation*)operation{
    [self.operas addObject:operation];
    
    if([operation isKindOfClass:[ValueOperation class]]){
        [self.valueOps addObject:operation];
        
    }else if([operation isKindOfClass:[PrerequisiteOperation class]]){
        [self.prepres addObject:operation];
        
    }else if([operation isKindOfClass:[FUNCOperation class]]){
        [self.funcs addObject:operation];
        
    }else if([operation isKindOfClass:[JoinOperation class]]){
        
        self.joins = (JoinOperation *)operation;
        
    }else{
        if([operation isKindOfClass:[GROUPOperation class]]){
            [self.assists replaceObjectAtIndex:0 withObject:operation];
        }else if([operation isKindOfClass:[ORDEROperation class]]){
            [self.assists replaceObjectAtIndex:1 withObject:operation];
        }else if([operation isKindOfClass:[LimitOperation class]]){
            [self.assists replaceObjectAtIndex:2 withObject:operation];
        }else{
            NSAssert(NO, @"operation 你是什么类型");
        }
    }
    return self;
}
-(NSString *)sql{
    if(_hasParser){return _sql;}
    NSArray *tempSQLS = [_sql componentsSeparatedByString:@"where"];
    //select * from t_table
    NSString *befor = [tempSQLS firstObject];
    // '1' = '1'
    NSString *last = [tempSQLS lastObject];
    
    //字段 * / name,age,MAX(age),AVG(age)...
    NSMutableArray *vas = [NSMutableArray array];
    [self.valueOps  enumerateObjectsUsingBlock:^(DBOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(!obj.isUse){
            obj.isUse = YES;
            [vas addObjectsFromArray:[(ValueOperation *)obj pros]];
        }
    }];
    [self.funcs enumerateObjectsUsingBlock:^(DBOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FUNCOperation *func = (FUNCOperation *)obj;
        if(!func.isUse){
            func.isUse = YES;
            [vas addObject:func.content];
        }
    }];
    
    if(vas.count>=1){
        NSString *vastr = [vas componentsJoinedByString:@","];
        befor = [befor stringByReplacingOccurrencesOfString:@"*" withString:vastr];
    }
    //join
    if(self.joins && !self.joins.isUse){
        befor = [NSString stringWithFormat:@"%@ %@ ",befor,[self.joins content:self.valueC]];
        self.joins.isUse = YES;
    }
    
    // 条件 name like 'sas'
    NSMutableString *preStr = [NSMutableString string];
    [self.prepres enumerateObjectsUsingBlock:^(DBOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(!obj.isUse){
            PrerequisiteOperation *op = (PrerequisiteOperation *)obj;
            op.isUse = YES;
            [preStr appendFormat:@" %@ %@ ",op.isAnd? @"and" : @"or",op.content];
        }
    }];
    last = [last stringByAppendingString:preStr];
    // 辅助
    NSMutableString *asS = [NSMutableString string];
    [self.assists enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[AssistOperation class]]){
            AssistOperation *ao = (AssistOperation *)obj;
            if(!ao.isUse){
                ao.isUse = YES;
                [asS appendFormat:@" %@ ",[ao content]];
            }
        }
    }];
    last = [last stringByAppendingString:asS];
    
    if([befor containsString:@"*"] && self.joins){
        //由于 外连 不指定属性名 并且两张表 有相同名字的属性  导致后续 无法解析结果
        NSMutableArray *temp = [NSMutableArray array];
        [self.valueC enumerateIvar:^(NSString *proName) {
            [temp addObject:[PropertyCondition Condition:proName clazz:self.valueC]];
        }];
        befor = [befor stringByReplacingOccurrencesOfString:@"*" withString:[temp componentsJoinedByString:@","]];
    }
    
    _sql = [NSString stringWithFormat:@" %@ where %@",befor,last];
    _hasParser = YES;
    
    if([_sql containsString:@"'1' = '1'  and"]){
       _sql = [_sql stringByReplacingOccurrencesOfString:@"'1' = '1'  and  " withString:@""];
    }
    else{
        _sql = [_sql stringByReplacingOccurrencesOfString:@"where '1' = '1' " withString:@""];
    }
    return _sql;
}
-(id)values{
    if(!self.valueC){
        NSLog(@"必须指定 valueC 属性");
        return nil;
    }

    if(self.valueOps.count == 0){
        //没有指定查找字段
        if(self.funcs.count == 0)
            if(!self.joins)
                return [DataBaseConnect objectsWithSQL:self.sql resultClass:self.valueC];
            else{
                DBManager *manager = [DBManager shareDBManager];
                NSMutableArray *result = [NSMutableArray array];
                [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
                    FMResultSet *set = [database executeQuery:self.sql];
                    int count = [set columnCount];
                    while ([set next]) {
                        NSMutableDictionary *current = [NSMutableDictionary dictionary];
                        for (int i=0; i<count; i++) {
                            NSString *name = [set columnNameForIndex:i];
                            NSString *value = [set stringForColumnIndex:i];
                            id one  = [PropertyFactory valueForString:value block:^id<DBArhieverProtocol>(NSString *onself, __unsafe_unretained Class class) {
                                return [DataBaseConnect objectWithClass:class filed:@"oneself" value:onself];;
                            }];
                            current[[name componentsSeparatedByString:[PropertyCondition spearaStr]].lastObject]=one;
                        }
                        NSObject *one = [[self.valueC alloc]init];
                        [one setValuesForKeysWithDictionary:current];
                        [result addObject:one];

                    }
                    return YES;
                }];
                return result;//是个问题
            }
        else{
            //指定函数  count sum max min
            DBManager *manager = [DBManager shareDBManager];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
                FMResultSet *set  = [database executeQuery:self.sql];
                int count  = [set columnCount];
                while ([set next]) {
                    for (int i=0; i<count; i++) {
                        NSString *name= [set columnNameForIndex:i];
                        dic[name] = [set stringForColumnIndex:i];
                    }
                }
                return YES;
            }];
            return dic;
        }
    }else{
        //指定查找字段
        DBManager *manager = [DBManager shareDBManager];
        __block ValueOperation *valuesOpera;
        [self.valueOps enumerateObjectsUsingBlock:^(DBOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isMemberOfClass:[ValueOperation class]]) {
                valuesOpera = (ValueOperation *)obj;
            };
        }];
        //返回数组  [[a,b,c],[a,b,c],[a,b,c]]
        if(self.ValueArry){
            NSMutableArray<NSMutableArray *> *result = [NSMutableArray array];
            [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
                FMResultSet *set = [database executeQuery:self.sql];
                int count = [set columnCount];
                while ([set next]) {
                    NSMutableArray *current = [NSMutableArray array];
                    for (int i=0; i<count; i++) {
                        NSString *value = [set stringForColumnIndex:i];
                        id one  = [PropertyFactory valueForString:value block:^id<DBArhieverProtocol>(NSString *onself, __unsafe_unretained Class class) {
                            return [DataBaseConnect objectWithClass:class filed:@"oneself" value:onself];;
                        }];
                        [current addObject:one];
                    }
                    [result addObject:current];
                }
                return YES;
            }];
            return result;
        }else{
            /** 返回字典  {@"key1":[...],@"key2":[....]}*/
            NSMutableDictionary<NSString *,NSMutableArray*> *result = [NSMutableDictionary dictionary];
            
            [valuesOpera.pros enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL * _Nonnull stop) {
                result[[key isKindOfClass:[NSString class]] ? key : [(PropertyCondition *)key propertyName]] = [NSMutableArray array];
            }];
            
            [manager connectDatabaseOperation:^BOOL(FMDatabase *database) {
                FMResultSet *set = [database executeQuery:self.sql];
                int count = [set columnCount];
                while ([set next]) {
                    for (int i=0; i<count; i++) {
                        NSString *name = [set columnNameForIndex:i];
                        NSString *value = [set stringForColumnIndex:i];
                        id one  = [PropertyFactory valueForString:value block:^id<DBArhieverProtocol>(NSString *onself, __unsafe_unretained Class class) {
                            return [DataBaseConnect objectWithClass:class filed:@"oneself" value:onself];;
                        }];
                        [result[name] addObject:one];
                    }
                }
                return YES;
            }];
            return  result;
        }
    }
    return nil;
}
-(id)valuesForArray{
    return [self values];
}
-(id)valuesForDictionary{
    self.ValueArry = NO;
    id va = [self values];
    self.ValueArry = YES;
    return va;
}
@end

@implementation PrepareStatus (simple)
-(instancetype)initWithClass:(Class)clazz{
    if (self = [super init]) {
        self.valueC = clazz;
    }
    return self;
}
-(PrepareStatus * (^)(DBOperation * opera))AddOperation{
    __weak typeof(self) this  = self;
    return ^PrepareStatus *(DBOperation * opera){
        [this addOperation:opera];
        return self;
    };
}
@end
