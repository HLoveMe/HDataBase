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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
        需要注意的是 如果你多次运行这段代码 
        数据库会Video没有出现多次记录
        而 Author 出现多次
        这是由于 Video  实现了uniqueness 来确定其的唯一性
     
     */
    NSLog(@"%@",NSHomeDirectory());
    Video *v = [[Video alloc] init];
    v.name = @"爱情公寓";
    v.url = [NSURL URLWithString:@"http://www.baidu.com"];
    v.time = 3000.3;
    v.ID = @"100001";
    
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
    int a = 1;
    
}

@end
