//
//  DBBaseTargetProtocol.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GETSELMETHOD(name) if(_##name){return _##name;};\
SEL asel  = NSSelectorFromString(@"selBoxs:");\
if([self respondsToSelector:asel]){\
    NSString *_pro= NSStringFromSelector(_cmd);\
    NSValue *value =[self performSelector:asel withObject:_pro];\
    SEL resu;\
    [value getValue:&resu];\
    return resu;\
}\
return nil;

@protocol DBArhieverProtocol<NSObject>

/**
    拥有该属性即可 仅仅用于内部唯一标识
    值在数据中中为主键 且自动增长
    从  1 开始
    使用者 无需关系内部联系
 */
@required
@property(nonatomic,assign)long oneself;

//用于 限制存储的属性范围
@optional
-(NSArray *)ignoreFileds;

/**
  如果你的类有唯一标示  可以指定
 @return 指定作为唯一标示属性
 */
-(NSString *)uniqueness;
@end
