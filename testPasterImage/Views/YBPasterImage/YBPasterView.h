//
//  YBPasterView.h
//  testPasterImage
//
//  Created by 王迎博 on 16/9/6.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YBPasterViewDelegate <NSObject>
@required;
@optional;
@end

@interface YBPasterView : UIView

/**图片，所要加成贴纸的图片*/
@property (nonatomic, strong) UIImage *pasterImage;
/**隐藏删除和缩放按钮*/
- (void)hiddenBtn;

@end
