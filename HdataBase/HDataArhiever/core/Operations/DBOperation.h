//
//  DBOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/2.
//  Copyright © 2017年 Space. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBOperation : NSObject
/**
 values:
    ValueOperation 1
    DISTINOTOperation 2
 func:
    FUNCOperation 3
 
 prepres:
    CompareOperation 4
    LIKEOperation    5
    GLOBOperation    6
 
 assists:
    GROUPOperation 8
    ORDEROperation 9
    LimitOperation 10
 
 
*/
@property(nonatomic,assign)int level;
@property(nonatomic,assign)BOOL isUse;
@end
