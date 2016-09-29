//
//  YBFilterScrollView.m
//  testPasterImage
//
//  Created by 王迎博 on 16/9/27.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import "YBFilterScrollView.h"
#import "ImageUtil.h"
#import "ColorMatrix.h"

@interface YBFilterScrollView ()

/**被编辑过的图片*/
@property (nonatomic, strong) UIImage *editedImage;

@end

@implementation YBFilterScrollView
@synthesize insert_space;

- (void)loadScrollView {
    
    // 初始化内部控件
    [self initViews];
}

/**
 *  初始化内部控件
 */
- (void)initViews
{
    for (int i = 0; i < self.titleArray.count; i ++)
    {
        CGFloat filterBtnW_H = self.perButtonW_H;
        UIButton *filterBtn = [[UIButton alloc]init];
        filterBtn.frame = CGRectMake((i+1)*insert_space + filterBtnW_H*i, insert_space, filterBtnW_H, filterBtnW_H);
        filterBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        filterBtn.layer.borderWidth = 0.5;
        filterBtn.tag = 1000 + i;
        [filterBtn setBackgroundImage:[self buttonSetImageWithButton:filterBtn] forState:UIControlStateNormal];
        [filterBtn addTarget:self action:@selector(filterClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:filterBtn];
        
        CGFloat labelX = filterBtn.frame.origin.x;
        CGFloat labelY = CGRectGetMaxY(filterBtn.frame) + 5;
        CGFloat labelW = filterBtn.frame.size.width;
        CGFloat labelH = self.labelH - 5;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        label.text = [self.titleArray objectAtIndex:i];
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.];
        [self addSubview:label];
    }
}

/**
 *  设置button的预览图
 */
- (UIImage *)buttonSetImageWithButton:(UIButton *)button
{
    NSInteger currentIndex = button.tag - 1000;
    UIImage *buttonImage;
    switch (currentIndex)
    {
        case 0:
        {
            buttonImage = self.originImage;
        }
            break;
        case 1:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_lomo];
        }
            break;
        case 2:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_heibai];
        }
            break;
        case 3:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_huajiu];
        }
            break;
        case 4:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_gete];
        }
            break;
        case 5:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_ruise];
        }
            break;
        case 6:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_danya];
        }
            break;
        case 7:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_jiuhong];
        }
            break;
        case 8:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_qingning];
        }
            break;
        case 9:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_langman];
        }
            break;
        case 10:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_guangyun];
        }
            break;
        case 11:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_landiao];
        }
            break;
        case 12:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_menghuan];
        }
            break;
        case 13:
        {
            buttonImage = [ImageUtil imageWithImage:self.originImage withColorMatrix:colormatrix_yese];
        }
            break;
            
        default:
            break;
    }

    return buttonImage;
}

/**
 *  点击方法
 */
- (void)filterClick:(UIButton *)button
{
    self.editedImage = button.currentBackgroundImage;
    
    if (self.editedImage == nil) {
        self.editedImage = self.originImage;
    }
    
    //调用代理，把编辑过的当前按钮的图片传给控制器
    if (_filterDelegate && [_filterDelegate respondsToSelector:@selector(filterImage:)])
    {
        [_filterDelegate filterImage:button.currentBackgroundImage];
        NSString *string =  [_filterDelegate deliverStr:[NSString stringWithFormat:@"%@-%@",[self class],[self.titleArray objectAtIndex:button.tag - 1000]]];
        NSLog(@"%@",string);
    }
    
}



@end
