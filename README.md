# HDataBase
基于FMDB的封装   一行代码完成数据的读写

* 属性:

    1:只可以为 int long BOOL...
    
    2:NSNumber NSString  可序列化
    
    3:DBBaseTargetProtocol协议
    
    4:DBBaseTarget 子类
    
    5:数组
    * NSString ,NSNumber 可序列换
    * DBBaseTargetProtocol协议
    * DBBaseTarget 子类
    
    6:字典（同上）
 
    
    支持继承 支持属性(属性值 数据库保存)
    
* 注意
     * 如果数组字典  不必遵循泛型规则 @{@"name":@"ZZH",@"age":@(24),@"friend":[Student new]}
 
	 *  数组和字典不支持嵌套
* 使用:

    ```
        [DataBaseConnect saveObjectAllProperty:tea];
 
        [DataBaseConnect objectsWithClass:[Teacher class]];
 
        .......
	```