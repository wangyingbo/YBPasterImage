//
//  ViewController.m
//  testPasterImage
//
//  Created by 王迎博 on 16/9/5.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "ViewController.h"
#import "YBPasterImageVC.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES] ;
    [[UIApplication sharedApplication] setStatusBarHidden:YES] ;
}


/**
 *  跳转到下页
 */
- (IBAction)addPasterImage:(UIButton *)sender
{
    YBPasterImageVC *pasterVC = [[YBPasterImageVC alloc]init];
    pasterVC.originalImage = self.imageView.image;
    
    WS(weakSelf);
    pasterVC.block = ^(UIImage *editedImage){
        weakSelf.imageView.image = editedImage;
    };
    [self.navigationController pushViewController:pasterVC animated:YES];
    
}

@end
