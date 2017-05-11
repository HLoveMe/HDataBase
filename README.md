# HDataBase
基于FMDB的封装   一行代码完成数据的读写

* 协议
	* DBBaseTargetProtocol
   * @property(nonatomic,assign)long oneself;内部进行识别的标示
        dbFileds     剔除不需要保存的属性
* 属性:

	* 1:只可以为 int long BOOL...基本数据类型
   * 2:NSNumber NSString NSMutableString  NSURL NSDate NSAttributedString
   * 3:DBBaseTargetProtocol协议
   * 4:DBBaseTarget 子类
   * 5:数组
           * NSNumber NSString NSMutableString  NSAttributedString NSURL NSDate
           * DBBaseTargetProtocol协议
           * DBBaseTarget 子类
        
   * 6 字典:
   
	   	```
		key:value(NSNumber 	NSString ... ,DBBaseTargetProtocol)
	   ```
   
* 注意

        >你所需要保存数据库的模型 尽可能简单(不要包含逻辑代码)
            如果你的某些逻辑代码 导致增加属性(如果不需要进行数据库保存 dbFileds进行处理)
 
        >如果数组字典  不必遵循泛型规则 @{@"name":@"ZZH",@"age":@(24),@"friend":[Student new]}
 
        >数组和字典不支持嵌套
 
        >支持继承
 
        >支持 SEL
            由于SEL为指针  所以无法提供KVC直接获取(内部NSValue 包装 SEL)
            必须重写get方法
                看DBBaseTarget.m 示例
              或
                -(SEL)ASEL{
                    GETSELMETHOD(ASEL)
                }
 
        >支持 id  one (从数据库读取时  无法判断类型)
            所以仅仅支持（NSString , DBBaseTargetProtocol）
 
        >支持 结构体 NSRange   CGRECT CGSize CGPoint  
            不支持自定义
* 操作符

	|操作符|含义|sql|
	|----|------|----|
	|GROUPOperation.h|对某个字段Group操作|group by xx|
	|ORDEROperation.h|对某个字段升序和降序|order by age|
	|LimitOperation.h|分页操作|limit 10 offset 10|
	|||
	|CompareOperation.h|条件|where age >= 18|
	|LIKEOperation.h|模糊查询|where name LIKE '%无名氏%'|
	|GLOBOperation.h|模糊查询|where name GLOB '朱*'|
	|||
	|ValueOperation.h|查询字段指定|select name from table|
	|DISTINOTOperation.h|字段去重|select DISTINOT name from table|
	|||
	|CountOperation.h|数目|select count( * ) from table|
	|MAXOperation.h|最大值|select MAX(age) from table|
	|MINOperation.h|最小值|select MIN(age) from table|
	|AVGOperation.h|平均值|select AVG(age) from table|
	|SUMOperation.h|求和|select SUM(成绩) from table|
	|||
	|INNEROPeration|内联| A INNER JOIN B|
	|CROSSOperation|交叉| A CROSS JOIN B|
	|LeftOUTEROperation|左外联| A LEFT OUTER JOIN B|

* 使用:

    ```
        [DataBaseConnect saveObjectAllProperty:tea];
 
        [DataBaseConnect objectsWithClass:[Teacher class]];
 
	     。。。。
	```
	
* 操作符使用
	
	```
	//我仅仅想关心工资 和 姓名  按照工资降序 排列
    
    id valu  = [[[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[ValueOperation Operation:@[@"name",@"alalry"]]] addOperation:[ORDEROperation Operation:@"-alalry"]] values];
    
    //简便方式
    id valu2 = DataBaseConnect.prepare([People class])
    .AddOperation([ValueOperation Operation:@[@"name",@"alalry"]])
    .AddOperation([ORDEROperation Operation:@"-alalry"])
    .values;
    
    
    看Dome
	```
	
