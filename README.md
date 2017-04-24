# HDataBase
基于FMDB的封装   一行代码完成数据的读写

* 属性:

	* 1:只可以为 int long BOOL...基本数据类型
   * 2:NSNumber NSString NSMutableString NSAttributedString
   * 3:DBBaseTargetProtocol协议
   * 4:DBBaseTarget 子类
   * 5:数组
           * NSNumber NSString NSMutableString NSAttributedString
           * DBBaseTargetProtocol协议
           * DBBaseTarget 子类
        
   * 6 字典:
   	```
key:value(NSNumber NSString ... ,DBBaseTargetProtocol)
   ```
   
* 注意

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
* 使用:

    ```
        [DataBaseConnect saveObjectAllProperty:tea];
 
        [DataBaseConnect objectsWithClass:[Teacher class]];
 
        .......
	```