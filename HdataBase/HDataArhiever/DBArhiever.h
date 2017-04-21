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

#import "classExtension.h"
#import "propertys.h"

#import "DBBaseTargetProtocol.h"
#import "DBBaseTarget.h"

/**
    1:只可以为 int long BOOL...
    2:NSNumber NSString  可序列化
    3:DBBaseTargetProtocol协议
    4:DBBaseTarget 子类
    5:数组{
            NSString ,NSNumber 可序列换
                    
            DBBaseTargetProtocol协议
 
            DBBaseTarget 子类
        }
    
    支持继承 支持属性(属性值 数据库保存)
 
    使用:
        [DataBaseConnect saveObjectAllProperty:tea];
 
        [DataBaseConnect objectsWithClass:[Teacher class]];

 */
