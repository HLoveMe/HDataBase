//
//  propertyViewControoler.m
//  HdataBase
//
//  Created by space on 16/2/27.
//  Copyright © 2016年 Space. All rights reserved.
//

#import "propertyViewControoler.h"
#import "FMDBTool.h"
#import "student.h"
#import "resultTableViewController.h"
@interface propertyViewControoler()
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UITextField *genderTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UITextField *weidthTextFielf;
@property (strong, nonatomic) IBOutlet UITextField *sorceTextField;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property(nonatomic,strong)UIWindow *customWindow;
@end
@implementation propertyViewControoler
-(UIWindow *)customWindow{
    if (!_customWindow) {
        UIWindow *temp = [[UIWindow alloc]initWithFrame:CGRectMake(0,0, 100, 30)];
        temp.center = self.view.center;
        temp.backgroundColor = [UIColor blackColor];
        temp.layer.cornerRadius = 5;
        UILabel *lab = [[UILabel alloc]initWithFrame:temp.bounds];
        lab.textAlignment = NSTextAlignmentCenter;
        [lab setTextColor:[UIColor whiteColor]];
        [temp addSubview:lab];
        _customWindow = temp;
    }
    return _customWindow;
}

- (IBAction)save:(id)sender {
    /**保存对象*/
    BOOL flag =0;
    student *stu = [self studentFromTextField];
    if (stu) {
            flag = [FMDBTool saveObjectAllProperty:stu];
//            flag = [FMDBTool H_saveObject:<#(NSObject *)#> onlyFlag:<#(NSString *)#>]
//            对象属性不能完全一致 有唯一标识
    }
    if(flag)
        [self showMessage:@"Success" time:2];
    else
        [self showMessage:@"failure" time:2];
}
- (IBAction)deleteData:(id)sender {
    [FMDBTool deleteObject:[self studentFromTextField]];
//    [FMDBTool H_deleteObjectByFlag:<#(NSString *)#> withClass:<#(__unsafe_unretained Class)#>]
}
- (IBAction)alldata:(id)sender {
    [self.navigationController pushViewController:[resultTableViewController new] animated:YES];
}
-(student *)studentFromTextField{
    student *stu = [[student alloc]init];
    if (self.nameTextField.text.length>=1) {
        stu.name = self.nameTextField.text;
    }
    if (self.ageTextField.text.length>1) {
        stu.age = [self.ageTextField.text intValue];
    }
    if (self.genderTextField.text.length>=1) {
        stu.gender = self.genderTextField.text;
    }
    if (self.addressTextField.text.length>=1) {
        stu.address = self.addressTextField.text;
    }
    if (self.weidthTextFielf.text.length>=1) {
        stu.weight= [self.weidthTextFielf.text doubleValue];
    }
    if (self.sorceTextField.text.length>=1) {
        stu.source = [self.sorceTextField.text intValue];
    }
    NSString *str= [NSString stringWithFormat:@"%@",stu];
    if (str.length<=1) {
        return nil;
    }
    return  stu;
}
-(void)showMessage:(NSString *)msg time:(double)time{
    UILabel *lab= [[self.customWindow subviews]lastObject];
    lab.text= msg;
    self.customWindow.hidden= NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        self.customWindow.hidden = YES;
    });
}
@end
