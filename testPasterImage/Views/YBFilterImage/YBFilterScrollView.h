//
//  YBFilterScrollView.h
//  testPasterImage
//
//  Created by 王迎博 on 16/9/27.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YBFilterScrollViewDelegate <NSObject>
@required;
- (void)filterImage:(UIImage *)editedImage;
@optional;
// 测试有返回值的代理
- (NSString *)deliverStr:(NSString *)originalStr;
@end


@interface YBFilterScrollView : UIScrollView

/**滤镜scrollView的高*/
@property (nonatomic, assign) CGFloat filterScrollViewW;
/**内切间距*/
@property (nonatomic, assign) CGFloat insert_space;
/**名字数组*/
@property (nonatomic, copy) NSArray *titleArray;
/**label的高*/
@property (nonatomic, assign) CGFloat labelH;
/**每个小方图的宽和高*/
@property (nonatomic, assign) CGFloat perButtonW_H;
/**原始图片*/
@property (nonatomic, strong) UIImage *originImage;
/**YBFilterScrollViewDelegate*/
@property (nonatomic,weak) id<YBFilterScrollViewDelegate> filterDelegate;

/**
 *  开始加载滤镜的scrollView
 */
- (void)loadScrollView;


@end
