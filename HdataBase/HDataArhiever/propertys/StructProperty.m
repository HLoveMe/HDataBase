//
//  StructProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "StructProperty.h"
#import <UIKit/UIKit.h>
@implementation StructProperty
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set class:(Class)clazz{
    NSString *sqlV = [set stringForColumn:self.name];
    NSString *cont = [[sqlV componentsSeparatedByString:@":"] lastObject];
    cont = [cont stringByReplacingOccurrencesOfString:@"{" withString:@""];
    cont = [cont stringByReplacingOccurrencesOfString:@"}" withString:@""];
    NSArray *nums = [cont componentsSeparatedByString:@","];
    if([sqlV containsString:@"NSRect"]){
        //rect
        float x = [nums[0] floatValue];
        float y = [nums[1] floatValue];
        
        float w = [nums[2] floatValue];
        float h = [nums[3] floatValue];
        return  [NSValue valueWithCGRect:CGRectMake(x, y, w, h)];
        
    }else if ([sqlV containsString:@"NSRange"]){
        float x = [nums[0] integerValue];
        float y = [nums[1] integerValue];
        return  [NSValue valueWithRange:NSMakeRange(x, y)];
    }else if ([sqlV containsString:@"NSSize"]){
        float w = [nums[0] floatValue];
        float h = [nums[1] floatValue];
        return  [NSValue valueWithCGSize:CGSizeMake(w, h)];
    }else if ([sqlV containsString:@"NSPoint"]){
        float x = [nums[0] floatValue];
        float y = [nums[1] floatValue];
        return  [NSValue valueWithCGPoint:CGPointMake(x, y)];
    }else{
        NSAssert(NO, @"结构体解析失败");
    }
    return nil;
}
@end
