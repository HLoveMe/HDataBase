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
#import "FMDB.h"
#import "PropertyFactory.h"
@interface PrepareStatus()
//所有
@property(nonatomic,strong)NSMutableArray<DBOperation *> *operas;

@property(nonatomic,strong)NSMutableArray<DBOperation *> *valueOps;
@property(nonatomic,strong)NSMutableArray<DBOperation *> *prepres;
@property(nonatomic,strong)NSMutableArray<DBOperation *> *assists;
@property(nonatomic,strong)NSMutableArray<DBOperation *> *funcs;
@end
@implementation PrepareStatus
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
        
    }else{
        if([operation isKindOfClass:[GROUPOperation class]]){
            [self.assists replaceObjectAtIndex:0 withObject:operation];
        }else if([operation isKindOfClass:[ORDEROperation class]]){
            [self.assists replaceObjectAtIndex:1 withObject:operation];
        }else if([operation isKindOfClass:[LimitOperation class]]){
            [self.assists replaceObjectAtIndex:2 withObject:operation];
        }else{
            NSAssert(NO, @"你是什么类型");
        }
    }
    return self;
}
-(NSString *)sql{
    NSArray *tempSQLS = [_sql componentsSeparatedByString:@"where"];
    NSString *befor = [tempSQLS firstObject];
    NSString *last = [tempSQLS lastObject];
    
    NSMutableArray *vas = [NSMutableArray array];
    [self.valueOps  enumerateObjectsUsingBlock:^(DBOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(!obj.isUse){
            obj.isUse = YES;
            [vas addObjectsFromArray:[(ValueOperation *)obj names]];
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
    //
    NSMutableString *preStr = [NSMutableString string];
    [self.prepres enumerateObjectsUsingBlock:^(DBOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(!obj.isUse){
            PrerequisiteOperation *op = (PrerequisiteOperation *)obj;
            op.isUse = YES;
            [preStr appendFormat:@" %@ %@ ",op.isAnd? @"and" : @"or",op.content];
        }
    }];
    last = [last stringByAppendingString:preStr];
    
    //
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
    _sql = [NSString stringWithFormat:@" %@ where %@",befor,last];
    
    return _sql;
}
-(id)values{
    if(self.valueOps.count == 0){
        if(self.funcs.count == 0)
            return [DataBaseConnect objectsWithSQL:self.sql resultClass:self.valueC];
        else{
            //count sum max min
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
        DBManager *manager = [DBManager shareDBManager];
        __block ValueOperation *valuesOpera;
        [self.operas enumerateObjectsUsingBlock:^(DBOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isMemberOfClass:[ValueOperation class]]) {
                valuesOpera = (ValueOperation *)obj;
            };
        }];
        
        NSMutableDictionary<NSString *,NSMutableArray*> *result = [NSMutableDictionary dictionary];
        
        [valuesOpera.names enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            result[key] = [NSMutableArray array];
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
    return nil;
}
@end
