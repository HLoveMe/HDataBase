//
//  DBArhiever.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/19.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "DataBaseConnect.h"

#import "DBManager.h"

#import "IvarInfomation.h"

#import "propertys.h"

#import "DBBaseTargetProtocol.h"

#import "DBBaseTarget.h"


/**
    DBBaseTargetProtocol
        @property(nonatomic,assign)long oneself;仅仅内部进行识别的标示
        ignoreFileds     剔除不需要保存的属性
        -(NSString *)uniqueness;  指定你的Model 唯一性 的属性名称 可选
 
    1:只可以为 int long BOOL...基本数据类型
    2:NSNumber NSString NSMutableString NSURL NSDate
    3:DBBaseTargetProtocol协议
    4:DBBaseTarget 子类
    5:数组{
            NSNumber NSString NSMutableString NSURL NSDate
 
            DBBaseTargetProtocol协议
 
            DBBaseTarget 子类
 
        }
    字典:
        NSDicTionary {
                key:value(NSNumber NSString ... ,DBBaseTargetProtocol)
        }
注意
        >你所需要保存数据库的模型 尽可能简单(不要包含逻辑代码)
            如果你的某些逻辑代码 导致增加属性(如果不需要进行数据库保存 ignoreFileds进行处理)
 
        >如果数组字典  不必遵循泛型规则 @{@"name":@"ZZH",@"age":@(24),@"friend":[Student new]}
 
        >数组和字典不支持嵌套
 
        >支持继承
 
        >支持 SEL
            由于SEL为指针  所以无法提供KVC直接获取(内部NSValue 包装 SEL)
            必须重写get方法
                看DBBaseTarget.m 示例
              或
                -(SEL)ASEL{
                    GETSELMETHOD(ASEL)
                }
 
        >支持 id  one (从数据库读取时  无法判断类型) 
            所以仅仅支持（NSString , DBBaseTargetProtocol）
 
        >支持 结构体 NSRange   CGRECT CGSize CGPoint  
            不支持自定义
使用:
        在调试阶段  任何属性名称/类型  类名变化 都需要调整数据库 否则不能正常运行
        [DataBaseConnect saveObjectAllProperty:tea];
 
        [DataBaseConnect objectsWithClass:[Teacher class]];

 */
