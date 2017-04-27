//
//  ClassManager.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/27.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "ClassManager.h"

@implementation ClassManager
+(BOOL)isEnCode:(id)value;{
    return [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSURL class]] ||[value isKindOfClass:[NSDate class]];
}
+(Class)valueClass:(id)value{
    if(!value)return [NSString class];
    if([value isKindOfClass:[NSString class]]){
        return [NSMutableString class];
    }else if([value isKindOfClass:[NSNumber class]]){
        return [NSNumber class];
    }else if([value isKindOfClass:[NSArray class]]){
        return [NSMutableArray class];
    }else if([value isKindOfClass:[NSDictionary class]]){
        return [NSMutableDictionary class];
    }else if([value isKindOfClass:[NSDate class]]){
        return [NSDate class];
    }else if([value isKindOfClass:[NSURL class]]){
        return [NSURL class];
    }
    return [value class];
}
@end
