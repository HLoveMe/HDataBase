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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"%@",NSHomeDirectory());
    [DataBaseConnect createTable:[Dog class]];
    [DataBaseConnect createTable:[Dog class]];
    
    [super viewDidLoad];
    /**
        需要注意的是 如果你多次运行这段代码 
        数据库会Video没有出现多次记录
        而 Author 出现多次
        这是由于 Video  实现了uniqueness 来确定其的唯一性
     
     */
    [DataBaseConnect update2:[Video class] dataChange:^id<DBArhieverProtocol>(NSDictionary *value) {
        
        return nil;
    }];
    
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
