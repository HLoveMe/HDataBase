//
//  SELProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "SELProperty.h"

@implementation SELProperty
-(NSString *)getReadValue:(long(^)(id<DBArhieverProtocol> obj))block value:(id)value{
    SEL asel;
    NSValue *temp = value;
    [temp getValue:&asel];
    NSString *selstr = NSStringFromSelector(asel);
    return selstr ? selstr : [Property nullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set class:(Class)clazz{
    NSString *sqlV = [set stringForColumn:self.name];
    if(!sqlV)return nil;
    SEL asel = NSSelectorFromString(sqlV);
    return  [NSValue value:&asel withObjCType:@encode(SEL)];
}
@end
