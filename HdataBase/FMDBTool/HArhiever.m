//
//  ZZHArhiever.m
//  runtime归档接档
//

#import "HArhiever.h"
@implementation HArhiever
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        unsigned int count;
        objc_property_t *pros = class_copyPropertyList([self class], &count);
        
        for (int i = 0; i<count; i++) {
            objc_property_t pro = pros[i];
            const char *name =property_getName(pro);
            
            // 归档
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [coder decodeObjectForKey:key];
            
            // 设置到成员变量身上
            [self setValue:value forKey:key];
        }
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count;
    objc_property_t *pros = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i<count; i++) {
         objc_property_t pro = pros[i];
       const char *name =property_getName(pro);
        // 归档
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

@end
