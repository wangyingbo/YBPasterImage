//
//  YBPasterScrollView.m
//  testPasterImage
//
//  Created by 王迎博 on 16/9/5.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "YBPasterScrollView.h"


#define defaultPasterImageW_H pasterScrollView_H - 2 * inset_space
/**底部scrollView的高*/
extern CGFloat pasterScrollView_H;
/**贴纸直接间隔距离*/
const CGFloat inset_space = 15;


@interface YBPasterScrollView ()

@end


@implementation YBPasterScrollView

/**
 *  重新自定义scrollView
 *
 *  @param pasterImageArray 底部贴纸的图片
 *
 *  @return 返回一个scrollView
 */
- (instancetype)initScrollViewWithPasterImageArray:(NSArray *)pasterImageArray
{
    if (self = [super init]) {
        
        self.pasterImageArray = pasterImageArray;
        self.pasterImage_W_H = pasterScrollView_H - inset_space * 2;
        
        [self setupUI];
        
    }
    return self;
}

/**
 *  设置UI
 */
- (void)setupUI
{
    for (int i = 0; i < self.pasterImageArray.count; i ++)
    {
        CGFloat pasterBtnW_H = self.pasterImage_W_H;
        UIButton *pasterBtn = [[UIButton alloc]init];
        pasterBtn.frame = CGRectMake((i+1)*inset_space + pasterBtnW_H*i, inset_space, pasterBtnW_H, pasterBtnW_H);
        [pasterBtn setImage:self.pasterImageArray[i] forState:UIControlStateNormal];
        pasterBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        pasterBtn.layer.borderWidth = 0.5;
        pasterBtn.tag = 1000 + i;
        [pasterBtn addTarget:self action:@selector(pasterClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pasterBtn];
    }
}

/**
 *  点击选取贴纸
 */
- (void)pasterClick:(UIButton *)sender
{
    if (_pasterDelegate && [_pasterDelegate respondsToSelector:@selector(pasterTag:pasterImage:)]) {
        
        [_pasterDelegate pasterTag:sender.tag - 1000 pasterImage:[self.pasterImageArray objectAtIndex:sender.tag - 1000]];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
}
@end
