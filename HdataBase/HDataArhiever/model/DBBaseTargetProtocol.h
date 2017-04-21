//
//  DBBaseTargetProtocol.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol DBArhieverProtocol<NSObject>
//仅仅用于内部唯一标识 可以不做理会
/**
    如果你修改此值 将会在保存数据库后被内部悄悄修改
    值在数据中中为主键 且自动增长
    从  1 开始
 */
@property(nonatomic,assign)long oneself;

//用于 限制存储的属性范围    需要保存属性
-(NSArray *)dbFileds;
@end
