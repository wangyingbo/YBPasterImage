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
#import "YBCustomButton.h"
#import "BlocksKit.h"
#import "BlocksKit+UIKit.h"
#import "YBFilterScrollView.h"


/**
 *  "滤镜"，“标签”，“贴纸”
 */
typedef NS_ENUM(NSInteger, YBImageDecoration) {
    /*** 滤镜*/
    YBImageFilter = 0,
    /*** 标签*/
    YBImageTag,
    /*** 贴纸*/
    YBImagePaster,
};

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

@interface YBPasterImageVC ()<YBPasterScrollViewDelegate, YBFilterScrollViewDelegate, YBPasterViewDelegate>
{
    NSInteger defaultIndex;
}
/**上部的图片imageView*/
@property (nonatomic, strong) UIImageView *pasterImageView;
/**多个贴纸样式的scrollView*/
@property (nonatomic, strong) YBPasterScrollView *pasterScrollView;
/**装多个滤镜样式的scrollView*/
@property (nonatomic, strong) YBFilterScrollView *filterScrollView;
/**图片数组*/
@property (nonatomic, copy) NSArray *imageArray;
/**可变的装多个贴纸标签的数组*/
@property (nonatomic, copy) NSMutableArray *pasterViewMutArr;
/**贴纸*/
@property (nonatomic, strong) YBPasterView *pasterView;
/**底部的公共的按钮*/
@property (nonatomic, strong) YBCustomButton *bottomButton;
/**底部滑动的红色的线*/
@property (nonatomic, strong) UIView *lineView;

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

- (void)dealloc
{
    NSLog(@"dealloc");
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
    if (!_imageArray) {
        NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:0];
        NSArray *arr = @[@"1",@"2",@"3",@"4",@"5"];
        for (NSString *imageName in arr) {
            UIImage *image = [UIImage imageNamed:imageName];
            [mutArr addObject:image];
        }
        _imageArray = mutArr;
    }
    
    return _imageArray;
}

/**
 *  懒加载-get方法设置自定义贴纸的scrollView
 */
- (YBPasterScrollView *)pasterScrollView
{
    if (!_pasterScrollView) {
        _pasterScrollView = [[YBPasterScrollView alloc]initScrollViewWithPasterImageArray:self.imageArray];
        _pasterScrollView.frame = CGRectMake(0, FULL_SCREEN_H - pasterScrollView_H - bottomButtonH, FULL_SCREEN_W, pasterScrollView_H);
        _pasterScrollView.backgroundColor = [UIColor lightGrayColor];
        _pasterScrollView.showsHorizontalScrollIndicator = YES;
        _pasterScrollView.bounces = YES;
        _pasterScrollView.contentSize = CGSizeMake(_pasterScrollView.pasterImage_W_H * _pasterScrollView.pasterImageArray.count + inset_space * 6, pasterScrollView_H);
        _pasterScrollView.pasterDelegate = self;
    }
    
    return _pasterScrollView;
}

/**
 *  懒加载-get方法设置自定义滤镜的scrollView
 */
- (YBFilterScrollView *)filterScrollView
{
    if (!_filterScrollView) {
        _filterScrollView = [[YBFilterScrollView alloc]initWithFrame:CGRectMake(0, FULL_SCREEN_H - pasterScrollView_H - bottomButtonH, FULL_SCREEN_W, pasterScrollView_H)];
        _filterScrollView.backgroundColor = [UIColor lightGrayColor];
        _filterScrollView.showsHorizontalScrollIndicator = YES;
        _filterScrollView.bounces = YES;
        NSArray *titleArray = @[@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"瑞华",@"淡雅",@"酒红",@"青柠",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色"];
        _filterScrollView.titleArray = titleArray;
        _filterScrollView.filterScrollViewW = pasterScrollView_H;
        _filterScrollView.insert_space = inset_space*2/3;
        _filterScrollView.labelH = 30;
        _filterScrollView.originImage = self.originalImage;
        _filterScrollView.perButtonW_H = _filterScrollView.filterScrollViewW - 2*_filterScrollView.insert_space - 30;
        
        _filterScrollView.contentSize = CGSizeMake(_filterScrollView.perButtonW_H * titleArray.count + _filterScrollView.insert_space * (titleArray.count + 1), pasterScrollView_H);
        _filterScrollView.filterDelegate = self;
        [_filterScrollView loadScrollView];
    }
    return _filterScrollView;
}

/**
 *  设置UI
 */
- (void)setupUI
{
    //默认选中“滤镜”位置
    defaultIndex = 0;
    
    UIImageView *pasterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 100, FULL_SCREEN_W - 40, FULL_SCREEN_W - 40)];
    pasterImageView.image = self.originalImage;
    pasterImageView.userInteractionEnabled = YES;
    [self.view addSubview:pasterImageView];
    self.pasterImageView = pasterImageView;
    
    UIView *bottomBackView = [[UIView alloc]initWithFrame:CGRectMake(0, FULL_SCREEN_H - bottomButtonH, FULL_SCREEN_W, bottomButtonH)];
    bottomBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBackView];
    
    NSArray *array = @[@"滤镜",@"标签",@"贴纸"];
    for (int i = 0; i < array.count; i ++)
    {
        CGFloat perButtonW = FULL_SCREEN_W/3;
        YBCustomButton *button = [[YBCustomButton alloc]initWithFrame:CGRectMake(perButtonW * i , 0, perButtonW, bottomButtonH)];
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        button.tag = 5000 + i;
        if (i == defaultIndex) {
            button.selected = YES;
            self.bottomButton = button;
        }
        [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomBackView addSubview:button];
    }
    
    CGFloat lineViewW = bottomBackView.frame.size.width/6;
    CGFloat lineViewX = bottomBackView.frame.size.width/6 - lineViewW/2;
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(lineViewX, bottomButtonH - 3, lineViewW, 3)];
    lineView.backgroundColor = [UIColor redColor];
    [bottomBackView addSubview:lineView];
    self.lineView = lineView;
    
    //底部“贴纸”的scrollView
    [self.view addSubview:self.pasterScrollView];
    self.pasterScrollView.hidden = YES;
    self.pasterScrollView.alpha = 0.0;
    
    //底部“滤镜”的scrollView
    [self.view addSubview:self.filterScrollView];
}

/**
 *  底部“滤镜”、“标签”、“贴纸”的按钮点击方法
 */
- (void)bottomButtonClick:(YBCustomButton *)sender
{
    self.bottomButton.selected  = NO;
    sender.selected = !sender.selected;
    self.bottomButton = sender;
    
    // 底部的lineView转移位置
    [self lineViewTransform:sender];
    
    // 根据当前的index切换底部的scrollView
    [self changeDecorateImageWithButtonTag:sender];
}

/**
 *  根据当前的index切换底部的scrollView
 */
- (void)changeDecorateImageWithButtonTag:(YBCustomButton *)sender
{
    // 当前位置是贴纸
    if (sender.tag - 5000 == YBImagePaster)
    {
        [UIView animateWithDuration:.5 animations:^{
            self.pasterScrollView.alpha = 1.0;
            self.pasterScrollView.hidden = NO;
            
            if (self.pasterView)
            {
                [self.pasterView showBtn];
            }
        }];
    }else
    {
        self.pasterScrollView.hidden = YES;
        self.pasterScrollView.alpha = .0;
        
        if (self.pasterView)
        {
            [self.pasterView hiddenBtn];
        }
    }
    
    // 当前位置是滤镜
    if (sender.tag - 5000 == YBImageFilter)
    {
        [UIView animateWithDuration:.5 animations:^{
            self.filterScrollView.alpha = 1.0;
            self.filterScrollView.hidden = NO;
        }];
    }
    else
    {
        self.filterScrollView.hidden = YES;
        self.filterScrollView.alpha = .0;
    }
}

/**
 *  底部的lineView转移位置
 */
- (void)lineViewTransform:(YBCustomButton *)sender
{
    CGFloat sendW = sender.frame.size.width;
    NSInteger currentIndex = sender.tag - 5000;
    CGFloat lineViewH = self.lineView.frame.size.height;
    CGFloat lineViewX = sendW * currentIndex + sendW / 2 - self.lineView.frame.size.width/2;
    CGFloat lineViewY = bottomButtonH - lineViewH;
    CGFloat lineViewW = sendW/2;
    [UIView animateWithDuration:.5 animations:^{
        self.lineView.frame = CGRectMake(lineViewX, lineViewY, lineViewW, lineViewH);
    }];
}

/**
 *  导航栏的“完成”右键
 */
- (void)setRightButton
{
    [self initRightButtonWithButtonW:50 buttonH:50 title:@"完成" titleColor:[UIColor redColor] touchBlock:^(UIButton *rightButton) {
    }];
    
    WS(weakSelf);
    //按钮的点击事件封装的block
    weakSelf.rightBtnBlock = ^(NSString *string){
        NSLog(@"完成了添加贴纸");
        [weakSelf.pasterView hiddenBtn];
        if (weakSelf.block) {
            
            if (weakSelf.pasterView != nil) {
                UIImage *editedImage = [weakSelf doneEdit];
                weakSelf.block(editedImage);
            }
            else
            {
                weakSelf.block(weakSelf.pasterImageView.image);
            }
            
            [weakSelf.pasterImageView removeFromSuperview];
            [weakSelf.filterScrollView removeFromSuperview];
            [weakSelf.navigationController popViewControllerAnimated:YES];
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
    rect.size = CGSizeMake(self.pasterImageView.frame.size.width, inScreenH) ;
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
    pasterView.delegate = self;
    [self.pasterImageView addSubview:pasterView];
    self.pasterView = pasterView;
    
    //[self.pasterViewMutArr addObject:pasterView];
    //NSLog(@"%lu",(unsigned long)self.pasterViewMutArr.count);
    
}

#pragma mark - YBFilterScrollViewDelegate
- (void)filterImage:(UIImage *)editedImage
{
    self.pasterImageView.image = editedImage;
}

#pragma mark - YBPasterViewDelegate
- (void)deleteThePaster
{
    self.pasterView = nil;
}
@end
