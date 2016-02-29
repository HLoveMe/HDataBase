//
//  resultTableViewController.m
//  HdataBase
//
//  Created by space on 16/2/27.
//  Copyright © 2016年 Space. All rights reserved.
//
#define  HRandomColor [UIColor  colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
#import "resultTableViewController.h"
#import "FMDBTool.h"
#import "student.h"
@interface resultTableViewController ()
@property(nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation resultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [FMDBTool ObjectsWithClass:[student class]].mutableCopy;
//    [FMDBTool H_ObjectsByClass:<#(__unsafe_unretained Class)#>]
    [self initRight];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",[NSBundle mainBundle].infoDictionary[@"CFBundleName"]]];
    NSLog(path);
}

-(void)initRight{
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"removeAll" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
    self.navigationItem.rightBarButtonItem = right;
}
-(void)remove{
    [self.dataArray removeAllObjects];
    [FMDBTool deleteAllObjects:[student class]];
//    [FMDBTool H_deleteAllObjectwithClass:<#(__unsafe_unretained Class)#>]
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseI"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseI"];
    }
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    UILabel *lab =[[UILabel alloc]initWithFrame:cell.contentView.bounds];
    lab.textAlignment = NSTextAlignmentCenter;
    student *stu= self.dataArray[indexPath.row];
    lab.text = [NSString stringWithFormat:@"%@",stu];
    [cell.contentView addSubview:lab];
    cell.contentView.backgroundColor= HRandomColor;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return  60;
}


@end
