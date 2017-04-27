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

@property(nonatomic,assign)BOOL allowClose;
@end
@implementation DBManager
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
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",[NSBundle mainBundle].infoDictionary[@"CFBundleName"]]];
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
    NSFileManager *file = [NSFileManager defaultManager];
    NSError *err;
    //删除上次文件
    if([file fileExistsAtPath:[self temppath]]){
        [file removeItemAtPath:[self temppath] error:&err]
        ;
        if(err){
            NSLog(@"%@",[NSString stringWithFormat:@"删除零时文件失败"]);
        }
    }
    err = nil;
    //保存零时文件
    [file copyItemAtPath:[self dbPath] toPath:[self temppath] error:&err];
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
        [file removeItemAtPath:[self temppath] error:nil];
    }else{
        NSLog(@"更新失败 数据回原");
        [file removeItemAtPath:[self dbPath] error:nil];
        [file copyItemAtPath:[self temppath] toPath:[self dbPath] error:&err];
        [file removeItemAtPath:[self temppath] error:nil];
        if(err)
            NSLog(@"%@",[NSString stringWithFormat:@"更新失败 数据回原失败"]);
    }
}
@end
