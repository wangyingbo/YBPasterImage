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
- (void)deleteThePaster;
@end

@interface YBPasterView : UIView

/**YBPasterViewDelegate*/
@property (nonatomic,weak) id<YBPasterViewDelegate> delegate;
/**图片，所要加成贴纸的图片*/
@property (nonatomic, strong) UIImage *pasterImage;
/**隐藏“删除”和“缩放”按钮*/
- (void)hiddenBtn;
/**显示“删除”和“缩放”按钮*/
- (void)showBtn;

@end
