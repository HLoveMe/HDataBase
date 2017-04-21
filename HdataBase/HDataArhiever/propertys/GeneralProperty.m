//
//  generalProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "GeneralProperty.h"

@implementation GeneralProperty
-(NSString *)getReadValue:(long (^)(id<DBArhieverProtocol>))block value:(id)value{
    return value ? value : [Property nullValue];
}
-(id)valueWithSet:(id<DBArhieverProtocol> (^)(NSString *, __unsafe_unretained Class))block set:(FMResultSet *)set{
    NSString *sqlv = [set stringForColumn:self.name];
    if([self dataBaseIsValue:sqlv]){
        return sqlv;
    }
    return nil;
}
@end
