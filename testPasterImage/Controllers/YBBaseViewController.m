//
//  YBBaseViewController.m
//  testPasterImage
//
//  Created by 王迎博 on 16/10/19.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "YBBaseViewController.h"

@interface YBBaseViewController ()

@end

@implementation YBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"%@ will appear", className);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
