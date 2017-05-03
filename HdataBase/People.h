//
//  People.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBArhiever.h"
@interface People : DBBaseTarget
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)int age;
@property(nonatomic,copy)NSString *address;
@property(nonatomic,assign)double alalry;
+(instancetype)people:(NSString*)name age:(int)age address:(NSString *)address sl:(double)sl;
@end
