//
//  UIViewController+Extension.h
//  Kergou
//
//  Created by 王迎博 on 16/4/28.
//  Copyright © 2016年 张帅. All rights reserved.
//

#import <UIKit/UIKit.h>

/**定义左边按钮block*/
typedef void(^backButtonBlock)(UIButton *BackButton);
/**定义右边按钮block*/
typedef void(^rightButtonBlock)(UIButton *rightButton);

/**定义左边按钮点击事件block*/
typedef void(^leftBtnTargetBlock)(NSString *string);
/**定义右边按钮点击事件block*/
typedef void(^rightBtnTargetBlock)(NSString *string);


@interface UIViewController (Extension)

@property (nonatomic, copy)   NSString *name;  //视图名字
@property (nonatomic, assign) BOOL  hasChildViewController;//是否有子视图
@property (nonatomic, strong) UIImage *backgroundImage;   //背景图片

/**右边按钮点击事件block*/
@property (nonatomic, copy) rightBtnTargetBlock rightBtnBlock;
/**左边按钮点击事件block*/
@property (nonatomic, copy) leftBtnTargetBlock leftBtnBlock;


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
                       touchBlock:(backButtonBlock)block;



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
                        touchBlock:(rightButtonBlock)block;



/**
 *  触摸屏幕隐藏键盘
 */
- (void)setUpForDismissKeyboard:(UIView *)selfView;




@end
