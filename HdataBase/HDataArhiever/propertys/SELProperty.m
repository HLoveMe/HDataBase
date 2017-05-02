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
    NSString *ss = NSStringFromSelector(asel);
    NSString *selstr = [NSString stringWithFormat:@"%@%@%@",ss,[Property separatedString],@"SEL"];
    return ss ? selstr : [Property nullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set sqlV:(NSString *)sqlV class:(Class)clazz{
    if(!sqlV)return nil;
    NSArray *res = [sqlV componentsSeparatedByString:[Property separatedString]];
    SEL asel = NSSelectorFromString(res[0]);
    return  [NSValue value:&asel withObjCType:@encode(SEL)];
}
@end
