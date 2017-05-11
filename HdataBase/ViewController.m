//
//  ViewController.m
//  HdataBase
//
//  Created by space on 16/2/27.
//  Copyright © 2016年 Space. All rights reserved.
//

#import "ViewController.h"
#import "DataBaseConnect.h"
#import "Video.h"
#import "Author.h"
#import "Dog.h"
#import "PrepareStatus.h"
#import "ValueOperation.h"
#import "LimitOperation.h"
#import "People.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"%@",NSHomeDirectory());
    [super viewDidLoad];
    
//    NSArray *ae = @[
//                   [People people:@"Paul" age:32 address:@"California" sl:20000.0],
//                   [People people:@"Allen" age:25 address:@"Texas" sl:15000.0],
//                   [People people:@"Teddy" age:23 address:@"Norway" sl:25000.0],
//                   [People people:@"Mark" age:25 address:@"Rich-Mond" sl:27000.0],
//                   [People people:@"David" age:27 address:@"Texas" sl:25000.0],
//                   [People people:@"Kim" age:22 address:@"South-Hall" sl:35000.0],
//                   [People people:@"James" age:24 address:@"Houston" sl:41000.0],
//                   ];
//     BOOL asasa = [DataBaseConnect saveObjscts:ae];
    
    
/**
 
    [DataBaseConnect update2:[Video class] dataChange:^id<DBArhieverProtocol>(NSDictionary *value) {
        
        return nil;
    }];
*/
    /** 操作符的使用*/
    
    //select * from table limit 2 offset 2
    id va1 = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[LimitOperation Operation:NSMakeRange(2, 2)]] values];
    
    // 排序 select * from table order by alalry
    id va2 = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[ORDEROperation Operation:@"alalry"]] values];
    
    // select name from table limit 1 offset 3
    id va3 =  [[[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[ValueOperation Operation:@[@"name"]]] addOperation:[LimitOperation  Operation:NSMakeRange(1, 3)]] values];
    
    //select * from table where alalry >= 3000
    id va4 = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[CompareOperation Operation:@"alalry" compare:D value:30000 and:YES]] values];
    
    //select * from table where name like %d%  名字包含d
    id va5 = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[LIKEOperation Operation:@"name" like:@"%d%" and:YES]] values ];
    
    //select * from table where name GLOG 'D*'  名字D 开头
    id va6 = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[GLOBOperation Operation:@"name" compera:@"D*" and:YES]] values];
    
     //select * from t_People  where  name GLOB '*m*'  and  alalry >= 3700.000000    ORDER BY age ASC   limit 3 offset 0
    PrepareStatus *statu  = [[[[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[GLOBOperation Operation:@"name" compera:@"*m*" and:YES]] addOperation:[ORDEROperation Operation:@"-age"]] addOperation:[CompareOperation Operation:@"alalry" compare:D value:37000 and:YES]] addOperation:[LimitOperation Operation:NSMakeRange(0, 3)]];
//    NSLog(@"%@",[statu sql]);
    id va7 = [statu values];
    
    //select MAX(age) from table
    id va8 =  [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[MAXOperation Operation:@"age"]] values];
    
    // select AVG(age)from table 平均年纪
    id va9  = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[AVGOperation Operation:@"age"]] values];
    //select sum(alalry) from table 和值
    id va10 = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[SUMOperation Operation:@"alalry"]] values];
    
    
    //我仅仅想关心工资 和 姓名  按照工资降序 排列
    
    id valu22  = [[[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[ValueOperation Operation:@[@"name",@"alalry"]]] addOperation:[ORDEROperation Operation:@"-alalry"]] values];
    
    //简便方式
    id v2alu2 = DataBaseConnect.prepare([People class]).AddOperation([ValueOperation Operation:@[@"name",@"alalry"]]).AddOperation([ORDEROperation Operation:@"-alalry"]).AddOperation([LimitOperation Operation:NSMakeRange(0, 3)]).values;
   
    //join

    
    //select  t_People.name AS People__name, t_Author.name AS Author__name from t_People   INNER JOIN t_Author USING (oneself)
    id dada2 = DataBaseConnect.prepare([People class]).AddOperation([[INNEROPeration alloc] initOperationJoin:[Author class] with:@"oneself"]).AddOperation([ValueOperation Operation:@[[PropertyCondition Condition:@"name" clazz:[People class]],[PropertyCondition Condition:@"name" clazz:[Author class]]]]).values;
    
    //没有指定字段 查询所有字段
    //select  t_People.name AS People__name, t_People.age AS People__age, t_People.address AS People__address, t_People.alalry AS People__alalry, t_People.oneself AS People__oneself from t_People   INNER JOIN t_Author USING (oneself)
    id dada2qq = [[DataBaseConnect objectsWithTarget:[People class]] addOperation:[[INNEROPeration alloc] initOperationJoin:[Author class] with:@"oneself"]].values;
    
    
    
    id dada2saqq = [[[DataBaseConnect objectsWithTarget:[People class]] addOperation:[[LeftOUTEROperation alloc] initOperationJoin:[Author class] with:@"oneself"]] addOperation:[MAXOperation Operation:[PropertyCondition Condition:@"age" clazz:[People class]]]].values;
    /**
     需要注意的是 如果你多次运行这段代码
     数据库会Video没有出现多次记录
     而 Author 出现多次
     这是由于 Video  实现了uniqueness 来确定其的唯一性
     
     */
    Video *v = [[Video alloc] init];
    NSMutableString *aaaaa = [[NSMutableString alloc]initWithString:@"爱情公寓"];
    v.name = aaaaa;
    v.url = [NSURL URLWithString:@"http://www.baidu.com"];
    v.time = 3000.3;
    v.ID = @"100001";
    v.info = @{@"AA":@(100),@"BB":[[NSURL alloc]initWithString:@"http://a.b.c"]};
    v.date = [NSDate new];
    
    
    Author *au = [[Author alloc]init];
    au.name = @"咸菜";
    au.age = 99;
    au.icon = @"http://www.test.cpm/image/a.png";
    //Author 必须也是实现DBArhieverProtocol
    
    v.author = au;
    
    //插入
    [DataBaseConnect saveObjectAllProperty:v];
    //修改
    v.name = @"爱情公寓2";
    [DataBaseConnect updataObject:v Agrms:@{@"ID":@"100001"}];
    //查找
    id obj = [DataBaseConnect objectWithClass:[Video class] filed:@"ID" value:@"100001"];
    NSArray *aus = [DataBaseConnect objectsWithClass:[Author class]];
    int wwa = 1;
    
}

@end
