//
//  GLOBOperation.h
//  HdataBase
//
//  Created by 朱子豪 on 2017/5/3.
//  Copyright © 2017年 Space. All rights reserved.
//

#import "PrerequisiteOperation.h"

@interface GLOBOperation : PrerequisiteOperation

/**
 模糊匹配    注意大小写
    ? (一个或者无)
    * (一个以上)
 exam:
    "*H"   以H结尾  并且字符为 2个以上  (ZZH,192H)
    "?H"   以H结尾  并且字符为 1个或者2个字符（H,AH）
    "*H*"  包含H    并且字符至少为3
    "?H*"  H为第一个后者第二个字符 并且后面有字符  (HSB,0H_UDU)
 
 @param msg NSString(属性名称) or  PropertyCondition
 @param com 条件
 @return self
 */
+(instancetype)Operation:(id)msg compera:(NSString *)com and:(BOOL)isAnd;
@end
