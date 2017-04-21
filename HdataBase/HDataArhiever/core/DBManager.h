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
-(void)connectDatabaseOperation:(BOOL(^)(FMDatabase *database))block;

@end
