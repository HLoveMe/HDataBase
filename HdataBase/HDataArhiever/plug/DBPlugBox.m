//
//  DBPlugBox.m
//  HdataBase
//
//  Created by 朱子豪 on 2017/4/28.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "DBPlugBox.h"
@interface DBPlugBox()
@property(nonatomic,strong)NSMutableDictionary *plugsDic;
@end
@implementation DBPlugBox
static DBPlugBox *box;
+(instancetype)shareBox{
    if(box == nil){
        box = [[DBPlugBox alloc]init];
        box.plugsDic = [NSMutableDictionary dictionary];
    }
    return box;
}
-(void)registOperate:(DBPlug *)plug for:(Class)clazz{
    NSString *key = NSStringFromClass(clazz);
    self.plugsDic[key] = plug;
}

-(DBPlug*)plugFor:(Class)clazz{
    NSString *key = NSStringFromClass(clazz);
    return self.plugsDic[key];;
}
@end
