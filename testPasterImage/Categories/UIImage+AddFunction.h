//  UIImage+AddFunction.h
//  testPasterImage
//
//  Created by 王迎博 on 16/9/5.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AddFunction)

+ (UIImage *)squareImageFromImage:(UIImage *)image
                     scaledToSize:(CGFloat)newSize ;

+ (UIImage *)getImageFromView:(UIView *)theView ;

@end