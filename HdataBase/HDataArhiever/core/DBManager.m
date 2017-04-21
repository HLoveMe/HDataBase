//
//  DBManager.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//
#import "FMDB.h"
#import "DBManager.h"
static id single;
@interface DBManager()
@property(nonatomic,strong)FMDatabase *database;
@end
@implementation DBManager
+(instancetype)shareDBManager{
    if (single == nil){
        [[DBManager  alloc]init];
    }
    return single;
}
-(instancetype)init{
    if (single == nil){
        self = [super init];
        single = self;
        self.database = [FMDatabase databaseWithPath:[self dbPath]];
    }
    return single;
}
-(FMDatabase *)dataBase{
    [self.database open];
    return self.database;
}
-(NSString *)dbPath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",[NSBundle mainBundle].infoDictionary[@"CFBundleName"]]];
}
-(void)connectDatabaseOperation:(BOOL(^)(FMDatabase *data))block{
    if (!self.database.open){
        [self.database open];
    }
    BOOL close = NO;
    if (block){
        close = block(self.database);
    }
    if (close)
        [self.database close];
}
@end
