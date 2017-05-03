//
//  MAXOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "FUNCOperation.h"

@interface MAXOperation : FUNCOperation
//select MAX(name) from table
+(instancetype)Operation:(NSString*)name;
@end
