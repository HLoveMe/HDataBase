//
//  ViewController.m
//  HdataBase
//
//  Created by space on 16/2/27.
//  Copyright © 2016年 Space. All rights reserved.
//

#import "ViewController.h"
#import "propertyViewControoler.h"
#import "FMDBTool.h"
#import "student.h"
#import "teacher.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *one;
@property (strong, nonatomic) IBOutlet UIButton *two;

@end

@implementation ViewController

- (void)viewDidLoad {
    [FMDBTool addColumn:[student class] name:@"AAAAAA"];
    [super viewDidLoad];
    
}
- (IBAction)onetouch:(id)sender {
    propertyViewControoler *one= [propertyViewControoler new];
    [self.navigationController pushViewController:one animated:true];
}
- (IBAction)twoTouch:(id)sender {
    propertyViewControoler *one= [propertyViewControoler new];
    [self.navigationController pushViewController:one animated:true];
}
@end
