//
//  YBPasterImageVC.m
//  testPasterImage
//
//  Created by 王迎博 on 16/9/5.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "YBPasterImageVC.h"
#import "UIViewController+Extension.h"
#import "YBPasterScrollView.h"
#import "YBPasterView.h"
#import "UIImage+AddFunction.h"


#define FULL_SCREEN_H [UIScreen mainScreen].bounds.size.height
#define FULL_SCREEN_W [UIScreen mainScreen].bounds.size.width
/**底部的scrollView的高*/
const CGFloat pasterScrollView_H = 120;
/**空白的距离间隔*/
extern CGFloat inset_space;
/**默认的图片上的贴纸大小*/
static const CGFloat defaultPasterViewW_H = 120;
/**底部按钮的高度*/
static CGFloat bottomButtonH = 44;


@interface YBPasterImageVC ()<YBPasterScrollViewDelegate>

/**上部的图片imageView*/
@property (nonatomic, strong) UIImageView *pasterImageView;
/**底部的自定义的scrollView*/
@property (nonatomic, strong) YBPasterScrollView *pasterScrollView;
/**图片数组*/
@property (nonatomic, copy) NSArray *imageArray;
/**可变的装多个贴纸标签的数组*/
@property (nonatomic, copy) NSMutableArray *pasterViewMutArr;
/**贴纸*/
@property (nonatomic, strong) YBPasterView *pasterView;

@end

@implementation YBPasterImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置一些通用属性
    [self setGeneralPropetory];
    
    //添加右键
    [self setRightButton];
    
    //设置UI
    [self setupUI];
    
}

/**
 *  设置一些通用属性
 */
- (void)setGeneralPropetory
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

/**
 *  懒加载-装多张贴纸的可变数组
 */
- (NSMutableArray *)pasterViewMutArr
{
    if (!_pasterViewMutArr) {
        _pasterViewMutArr = [NSMutableArray array];
    }
    return _pasterViewMutArr;
}

/**
 *  懒加载-图片数组
 */
- (NSArray *)imageArray
{
    NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *arr = @[@"1",@"2",@"3",@"4",@"5"];
    for (NSString *imageName in arr) {
        UIImage *image = [UIImage imageNamed:imageName];
        [mutArr addObject:image];
    }
    _imageArray = mutArr;
    
    return _imageArray;
}

/**
 *  懒加载-get方法设置自定义贴纸的scrollView
 */
- (YBPasterScrollView *)pasterScrollView
{
    _pasterScrollView = [[YBPasterScrollView alloc]initScrollViewWithPasterImageArray:self.imageArray];
    _pasterScrollView.frame = CGRectMake(0, FULL_SCREEN_H - pasterScrollView_H - bottomButtonH, FULL_SCREEN_W, pasterScrollView_H);
    _pasterScrollView.backgroundColor = [UIColor lightGrayColor];
    _pasterScrollView.showsHorizontalScrollIndicator = YES;
    _pasterScrollView.bounces = YES;
    _pasterScrollView.contentSize = CGSizeMake(_pasterScrollView.pasterImage_W_H * _pasterScrollView.pasterImageArray.count + inset_space * 6, pasterScrollView_H);
    _pasterScrollView.pasterDelegate = self;
    
    return _pasterScrollView;
}

/**
 *  设置UI
 */
- (void)setupUI
{
    [self.view addSubview:self.pasterScrollView];
    
    UIImageView *pasterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 100, FULL_SCREEN_W - 40, FULL_SCREEN_W - 40)];
    pasterImageView.image = self.originalImage;
    pasterImageView.userInteractionEnabled = YES;
    [self.view addSubview:pasterImageView];
    self.pasterImageView = pasterImageView;
    
    UIView *bottomBackView = [[UIView alloc]initWithFrame:CGRectMake(0, FULL_SCREEN_H - bottomButtonH, FULL_SCREEN_W, bottomButtonH)];
    bottomBackView.backgroundColor = [UIColor redColor];
    [self.view addSubview:bottomBackView];
    
    
    
}

/**
 *  右键
 */
- (void)setRightButton
{
    [self initRightButtonWithButtonW:50 buttonH:50 title:@"完成" titleColor:[UIColor redColor] touchBlock:^(UIButton *rightButton) {
    }];
    
    WS(weakSelf);
    weakSelf.rightBtnBlock = ^(NSString *string){
        NSLog(@"完成了添加贴纸");
        [self.pasterView hiddenBtn];
        if (weakSelf.block) {
            UIImage *editedImage = [weakSelf doneEdit];
            self.block(editedImage);
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    };
}

/**
 *  图片合成
 *
 *  @return 返回合成好的图片
 */
- (UIImage *)doneEdit
{
    CGFloat org_width = self.originalImage.size.width ;
    CGFloat org_heigh = self.originalImage.size.height ;
    CGFloat rateOfScreen = org_width / org_heigh ;
    CGFloat inScreenH = self.pasterImageView.frame.size.width / rateOfScreen ;
    
    CGRect rect = CGRectZero ;
    rect.size = CGSizeMake(FULL_SCREEN_W, inScreenH) ;
    rect.origin = CGPointMake(0, (self.pasterImageView.frame.size.height - inScreenH) / 2) ;
    
    UIImage *imgTemp = [UIImage getImageFromView:self.pasterImageView] ;
    UIImage *imgCut = [UIImage squareImageFromImage:imgTemp scaledToSize:rect.size.width] ;
    
    return imgCut ;
}

#pragma mark - YBPasterScrollViewDelegate
- (void)pasterTag:(NSInteger)pasterTag pasterImage:(UIImage *)pasterImage
{
    if (self.pasterView) {
        [self.pasterView removeFromSuperview];
        self.pasterView = nil;
    }
    YBPasterView *pasterView = [[YBPasterView alloc]initWithFrame:CGRectMake(0, 0, defaultPasterViewW_H, defaultPasterViewW_H)];
    pasterView.center = CGPointMake(self.pasterImageView.frame.size.width/2, self.pasterImageView.frame.size.height/2);
    pasterView.pasterImage = pasterImage;
    [self.pasterImageView addSubview:pasterView];
    self.pasterView = pasterView;
    
    //[self.pasterViewMutArr addObject:pasterView];
    //NSLog(@"%lu",(unsigned long)self.pasterViewMutArr.count);
    
}


@end
