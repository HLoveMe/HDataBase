//
//  JoinOperation.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/10.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "JoinOperation.h"
#import "DataBaseConnect.h"
#import "PropertyCondition.h"
#import "BaseModelUtil.h"
@interface JoinOperation()
@property(nonatomic,assign)Class target;
@property(nonatomic,strong)id condition;

@property(nonatomic,strong)NSArray *proAs;
@property(nonatomic,strong)NSArray *proBs;
@property(nonatomic,strong)NSArray *ands;
@property(nonatomic,strong)NSArray *compares;
@property(nonatomic,copy)NSString *Acontent;
@end
@implementation JoinOperation
-(NSString *)content:(Class)origin{
    return nil;
}
-(NSString *)content:(Class)origin Join:(NSString *)join{
    if(self.Acontent){return self.Acontent;}
    if(self.proBs && self.proAs){
        NSString * tname = [DataBaseConnect tableName:origin];
        NSString *  ttname = [DataBaseConnect tableName:_target];
        NSMutableString * con = [[NSMutableString alloc]init];
        [_proAs enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *temp=@"";
            if(idx>0){
                if(_ands){
                    if(_ands.count > (idx-1))
                        temp = [_ands[idx-1] boolValue] ? @"and" : @"or" ;
                    else
                        temp=@"and";
                }else{
                    temp=@"and";
                }
            }
            
            [con appendFormat:@" %@ %@.%@ %@ %@.%@ ",temp,tname,obj,_compares? _compares[idx] : @"=",ttname,_proBs[idx]];
        }];
        _Acontent = [[NSString alloc]initWithFormat:@" %@ %@ on %@",join,ttname,con];
    }else{
        NSString * con ;
        if([_condition isKindOfClass:[NSArray class]]){
            con = [NSString stringWithFormat:@"USING (%@)",[(NSArray *)_condition componentsJoinedByString:@","]];
        }else{
            if(_condition){
                con = [NSString stringWithFormat:@"USING (%@)",_condition];
            }else{
                
                con =[NSString stringWithFormat:@"USING (%@)",[BaseModelUtil uniqueness:origin]];
            }
        }
        _Acontent = [[NSString alloc]initWithFormat:@" %@ %@ %@", join,[DataBaseConnect tableName:_target],con];
    }
    return _Acontent;
}
-(instancetype)initOperationJoin:(Class)class with:(id)condition{
    if (self= [super init]) {
        self.target = class;
        self.condition = condition;
    }
    return self;
}
-(instancetype)initOperationJoin:(Class)class self:(NSArray *)ProAs other:(NSArray *)ProBs compare:(NSArray *)compares con:(NSArray<NSNumber*>*)ands;{
    if (self= [super init]) {
        NSAssert(ProAs != nil, @"self nil");
        NSAssert(ProBs != nil, @"other nil");
        NSAssert(ProAs.count == ProBs.count, @"self count != other");
        if(compares)
            NSAssert(compares.count == ProBs.count, @"compares count != other");
        if(ands)
            NSAssert(ands.count >= ProAs.count-1, @"ands count err");
        self.target = class;
        self.proAs =ProAs;
        self.proBs=ProBs;
        self.compares = compares;
        self.ands = ands;
    }
    return self;
}
@end
