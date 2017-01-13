//
//  UIViewController+Extension.m
//  Kergou
//
//  Created by 王迎博 on 16/4/28.
//  Copyright © 2016年 张帅. All rights reserved.
//

#import "UIViewController+Extension.h"
#import <objc/runtime.h>

static const void *kName = "name";
static const void *kHasChildViewController = @"hasChildViewController";
static const void *kBackgroundImage = @"backgroundImage";

static const void *leftBlock = &leftBlock;
static const void *rightBlock = &rightBlock;


@implementation UIViewController (Extension)
@dynamic leftBtnBlock;
@dynamic rightBtnBlock;

#pragma mark - 左边按钮点击事件block绑定
- (leftBtnTargetBlock)leftBtnBlock
{
    return objc_getAssociatedObject(self, leftBlock);
}

- (void)setLeftBtnBlock:(leftBtnTargetBlock)leftBtnBlock
{
    objc_setAssociatedObject(self, leftBlock, leftBtnBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 右边按钮点击事件block绑定
- (rightBtnTargetBlock)rightBtnBlock
{
    return objc_getAssociatedObject(self, rightBlock);
}

- (void)setRightBtnBlock:(rightBtnTargetBlock)rightBtnBlock
{
    objc_setAssociatedObject(self, rightBlock, rightBtnBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 字符串类型的动态绑定
- (NSString *)name
{
    return objc_getAssociatedObject(self, kName);
}

- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, kName, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - BOOL类型的动态绑定
- (BOOL)hasChildViewController
{
    return [objc_getAssociatedObject(self, kHasChildViewController) boolValue];
}

- (void)setHasChildViewController:(BOOL)hasChildViewController
{
    objc_setAssociatedObject(self, kHasChildViewController, [NSNumber numberWithBool:hasChildViewController], OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - 类类型的动态绑定
- (UIImage *)backgroundImage
{
    return objc_getAssociatedObject(self, kBackgroundImage);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    objc_setAssociatedObject(self, kBackgroundImage, backgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



//***************************************************************





/**
 *  添加左边返回按钮
 *
 *  @param buttonW        返回按钮宽
 *  @param buttonH        返回按钮高
 *  @param title          返回按钮的title
 *  @param titleColor     字体颜色
 *  @param buttonImage    北京图片
 *  @param negativeSpacer 间隔距离
 *  @param block          回调block
 */
- (void)initBackButtonWithButtonW:(CGFloat)buttonW
                          buttonH:(CGFloat)buttonH
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
                      buttonImage:(UIImage *)buttonImage
                   negativeSpacer:(CGFloat)negativeSpacer
                       touchBlock:(backButtonBlock)block
{
    [self.navigationItem.backBarButtonItem setTitle:@""];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (title.length != 0) {
        [backBtn setTitle:title forState:UIControlStateNormal];
    }else
    {
        if (buttonImage) {
            [backBtn setImage:buttonImage forState:UIControlStateNormal];
        }else
        {
            [backBtn setImage:[UIImage imageNamed:@"zuojiantou.png"] forState:UIControlStateNormal];
        }
    }
    
    if (titleColor) {
        [backBtn setTitleColor:titleColor forState:UIControlStateNormal];
    }else
    {
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if (buttonH!=0 && buttonW!=0) {
        backBtn.frame = CGRectMake(0,0, buttonW, buttonH);
    }else
    {
        backBtn.frame = CGRectMake(0,0, 40, 20);
    }
    
    [backBtn addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    if (negativeSpacer!=0) {
        //设置返回按钮到手机左边框的距离
        UIBarButtonItem *negativeSpa = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpa.width = -negativeSpacer;
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpa, barBtn ,nil];
    }else
    {
        self.navigationItem.leftBarButtonItem = barBtn;
    }
    
    block(backBtn);
}

/**
 *  左按钮点击方法
 */
- (void)backButtonClick:(UIButton *)backButton
{
    self.leftBtnBlock(@"左按钮");
}





/**
 *  添加右边返回按钮
 *
 *  @param buttonW    右边按钮宽
 *  @param buttonH    右边按钮高
 *  @param title      右边按钮的title
 *  @param titleColor 字体颜色
 *  @param block      回调block
 */
- (void)initRightButtonWithButtonW:(CGFloat)buttonW
                           buttonH:(CGFloat)buttonH
                             title:(NSString *)title
                        titleColor:(UIColor *)titleColor
                        touchBlock:(rightButtonBlock)block
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (buttonW!=0 && buttonH!=0) {
        
        rightButton.frame = CGRectMake(0,0, buttonW, buttonH);
    }else
    {
        rightButton.frame = CGRectMake(0,0, 40, 30);
    }
    
    if (title.length!=0) {
        [rightButton setTitle:title forState:UIControlStateNormal];
    }else
    {
        [rightButton setTitle:@"取消" forState:UIControlStateNormal];
    }
    
    if (titleColor) {
        [rightButton setTitleColor:titleColor forState:UIControlStateNormal];
    }else
    {
        [rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    block(rightButton);
}

/**
 *  右键点击方法
 */
- (void)rightButtonClick:(UIButton *)rightButton
{
    self.rightBtnBlock(@"右按钮");
}





/**
 *  触摸屏幕隐藏键盘
 */
- (void)setUpForDismissKeyboard:(UIView *)selfView
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [selfView addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [selfView removeGestureRecognizer:singleTapGR];
                }];
}

/**
 *  触摸屏幕隐藏键盘的事件
 */
- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    //此method会将self.view里所有的subview的first responder都resign掉
    [self.view endEditing:YES];
}

@end
