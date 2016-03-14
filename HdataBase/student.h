//
//  student.h
//  HdataBase
//
//  Created by space on 16/2/27.
//  Copyright © 2016年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HArhiever.h"
@interface student : HArhiever
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)int age;
@property(nonatomic,copy)NSString *gender;
@property(nonatomic,copy)NSString *address;
@property(nonatomic,assign)int source;
@property(nonatomic,assign)double weight;
-(instancetype)initWithName:(NSString*)name age:(int)age gender:(NSString *)gender address:(NSString *)address source:(int)source weight:(double)weight;
@end
