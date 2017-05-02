//
//  DBPlugBox.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/28.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DBPlug;
@interface DBPlugBox : NSObject

+(instancetype)shareBox;

/**
 为处理类增加插件

 @param plug 每个类只能拥有一个插件
 @param clazz 类
 */
-(void)registOperate:(DBPlug *)plug for:(Class)clazz;

-(DBPlug*)plugFor:(Class)clazz;

@end
