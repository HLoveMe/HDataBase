//
//  PropertyFactory.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Property.h"

#import "DBBaseTargetProtocol.h"
@interface PropertyFactory : NSObject
+(Property *)propertyWith:(objc_property_t) t value:(id)value;
@end
