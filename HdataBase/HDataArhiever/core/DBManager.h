//
//  DBManager.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@interface DBManager : NSObject

+(instancetype)shareDBManager;
-(FMDatabase *)dataBase;
//查找完成 指定是否关闭数据库
-(void)connectDatabaseOperation:(BOOL(^)(FMDatabase *database))block;


/**
 block 内部所有操作  不会关闭数据库  《除非你 直接调用 [database close]》
 block 调用完成后关闭数据库
 @param block 数据库操作
 */
-(void)connectDatabaseOperationNoClose:(void(^)(FMDatabase *database))block;


/**
 数据库升级 保证失败后撤销  必须保证为同步操作

 @param block
 */
-(void)dataUpdate:(BOOL(^)(FMDatabase *data))block;
@end
