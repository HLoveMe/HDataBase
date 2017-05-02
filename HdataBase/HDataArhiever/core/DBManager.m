//
//  DBManager.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//
#import "FMDB.h"
#import "DBManager.h"
static DBManager *single;
@interface DBManager()
@property(nonatomic,strong)FMDatabase *database;
@property(nonatomic,copy)NSString *dbPath;
@property(nonatomic,assign)BOOL allowClose;
@end
@implementation DBManager

+(void)setDBPath:(NSString *)path{
    DBManager *m = [self shareDBManager];
    m.dbPath = path;
}
+(instancetype)shareDBManager{
    if (single == nil){
        DBManager *m = [[DBManager  alloc]init];
        m.allowClose = YES;
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
    if(_dbPath)
        return _dbPath;
    self.dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",[NSBundle mainBundle].infoDictionary[@"CFBundleName"]]];
    return _dbPath;
}
-(NSString *)temppath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"temp_%@.db",[NSBundle mainBundle].infoDictionary[@"CFBundleName"]]];
}
-(void)connectDatabaseOperation:(BOOL(^)(FMDatabase *data))block{
    [self.database open];
    BOOL close = NO;
    if (block){
        close = block(self.database);
    }
    if (close&&_allowClose)
        [self.database close];
}
-(void)connectDatabaseOperationNoClose:(void(^)(FMDatabase *database))block{
    self.allowClose = NO;
    if(block){
        [self.database open];
        block(self.database);
    }
    self.allowClose = YES;
    [self.database close];
}
-(void)dataUpdate:(BOOL(^)(FMDatabase *data))block{
    NSString *temp = [self temppath];
    NSString *db = [self dbPath];
    NSFileManager *file = [NSFileManager defaultManager];
    NSError *err;
    //临时文件存在  处理方式 替换
    if([file fileExistsAtPath:temp]){
        [file removeItemAtPath:db error:&err];
        [file copyItemAtPath:temp toPath:db error:&err];
        if(err){
            NSLog(@"%@",[NSString stringWithFormat:@"临时文件存在  处理方式 替换 失败"]);
        }
    }
    err = nil;
    //保存零时文件
    [file copyItemAtPath:db toPath:temp error:&err];
    if(err){
        NSLog(@"%@",[NSString stringWithFormat:@"创建临时文件失败"]);
        return;
    }
    [self.database open];
    BOOL flag;
    if(block)
        flag = block(self.database);
    
    //操作后续处理
    err = nil;
    if(flag){
        [file removeItemAtPath:temp error:nil];
    }else{
        NSLog(@"更新失败 数据回原");
        [file removeItemAtPath:db error:nil];
        [file copyItemAtPath:temp toPath:db error:&err];
        [file removeItemAtPath:temp error:nil];
        if(err)
            NSLog(@"%@",[NSString stringWithFormat:@"更新失败 数据回原失败"]);
    }
}
@end
