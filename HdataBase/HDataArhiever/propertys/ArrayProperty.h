//
//  ArrayProperty.h
//  HChat
//
//  Created by 朱子豪 on 2017/4/21.
//  Copyright © 2017年 朱子豪. All rights reserved.
//

#import "Property.h"

@interface ArrayProperty : Property
//  表示数组值得类型
//@property(nonatomic,assign)ValueType vType;
////  表示数组值的class
//@property(nonatomic,assign)Class valueClass;

@property(nonatomic,strong)NSArray<NSNumber *> *vTypes;
@property(nonatomic,strong)NSArray<Class> *valuesClazzs;

-(id)value:(NSString *)value class:(Class)class;

//数组 字典不支持嵌套
-(BOOL)isCanSave:(id)value;

@end
