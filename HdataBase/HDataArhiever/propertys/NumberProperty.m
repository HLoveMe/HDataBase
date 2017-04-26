//
//  NumberProperty.m
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "NumberProperty.h"

@implementation NumberProperty

-(NSString *)getReadValue:(long (^)(id<DBArhieverProtocol>))block value:(id)value{
    return (value ? [value description] : @"0");
}

-(id)valueWithSet:(id<DBArhieverProtocol>(^)(NSString * onself,Class class))block set:(FMResultSet *)set class:(Class)clazz{
        NSNumber *value;
        char first = [self.type characterAtIndex:0];
        switch (first) {
            case 'i'://int
                value = [NSNumber numberWithInt:[set intForColumn:self.name]];
                break;
            case 'I':
                value = [NSNumber numberWithUnsignedInt:[set intForColumn:self.name]];
            case 'q':
                value = [NSNumber numberWithLongLong:[set longLongIntForColumn:self.name]];
            case 'Q':
                value = [NSNumber numberWithUnsignedLongLong:[set unsignedLongLongIntForColumn:self.name]];
            case 'd':
                value = [NSNumber numberWithDouble:[set doubleForColumn:self.name]];
            case 'L':
                value = [NSNumber numberWithLong:[set longForColumn:self.name]];
            case 'B':
                value = [NSNumber numberWithBool:[set boolForColumn:self.name]];
                
//                .....
            default:
                value = @([set doubleForColumn:self.name]);;
        }
    return value;
}
@end
