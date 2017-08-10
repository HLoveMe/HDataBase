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
//保存表 是否创建
@property(nonatomic,strong)NSMutableArray* tableExits;
@end
@implementation DBManager
-(NSMutableArray *)tableExits{
    if(_tableExits==nil){
        _tableExits = [[NSMutableArray alloc]init];
    }
    return _tableExits;
}
+(void)setDBPath:(NSString *)path{
    DBManager *m = [self shareDBManager];
    m.dbPath = path;
}
+(instancetype)shareDBManager{
    if (single == nil){
        DBManager *m = [[DBManager  alloc]init];
        single = m;
    }
    return single;
}
-(instancetype)init{
    if (single == nil){
        self = [super init];
        single = self;
        [self clearTempFile];
        self.database = [FMDatabase databaseWithPath:[self dbPath]];
        [self.database open];
    }
    return single;
}
-(void)addtableExits:(NSString*)name{
    [self.tableExits addObject:name];
}
-(BOOL)hasExitsTable:(NSString*)name{
    return [self.tableExits containsObject:name];
}
-(BOOL)clearTempFile{
    NSString *temp = [self temppath];
    NSString *db = [self dbPath];
    NSFileManager *file = [NSFileManager defaultManager];
    NSError *err;
    //临时文件存在  处理方式 替换
    if([file fileExistsAtPath:temp]){
        if(self.database &&self.dataBase.goodConnection){
            NSLog(@"当前数据库已经处于打开状态，不能进行复原操作");
            return NO;
        }
        [file removeItemAtPath:db error:&err];
        [file copyItemAtPath:temp toPath:db error:&err];
        [file removeItemAtPath:temp error:&err];
        if(err){
            NSLog(@"%@",[NSString stringWithFormat:@"临时文件存在  处理方式 替换 失败"]);
        }
    }
    return err == nil;
}
-(FMDatabase *)dataBase{
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
-(void)connectDatabaseOperationNoClose:(void(^)(FMDatabase *database))block{
    //队列处理
    block(self.database);
}
-(void)dataUpdate:(BOOL(^)(FMDatabase *data))block{
    void(^HANDLE)(void)=^(){
        NSString *temp = [self temppath];
        NSString *db = [self dbPath];
        NSFileManager *file = [NSFileManager defaultManager];
        NSError *err;
        //临时文件存在  处理方式 替换
        if(![self clearTempFile]){return;}
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
        
        [self.database close];
        //操作后续处理
        if(flag){
            [file removeItemAtPath:temp error:nil];
        }else{
            [self clearTempFile];
        }
    };
    if(![[NSThread currentThread] isMainThread]){
        dispatch_sync(dispatch_get_main_queue(), ^{
            HANDLE();
        });
        return;
    }
    HANDLE();
}
@end
