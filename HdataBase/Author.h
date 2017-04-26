//
//  Author.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/26.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBArhiever.h"
@interface Author : DBBaseTarget
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)int age;
@property(nonatomic,copy)NSString *icon;
@end
