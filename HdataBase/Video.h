//
//  Video.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/26.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBArhiever.h"
@class Author;
@interface Video : DBBaseTarget
@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)long time;
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)Author *author;
@property(nonatomic,strong)id test;
@property(nonatomic,strong)NSDictionary *info;
@property(nonatomic,strong)NSDate *date;
@end
