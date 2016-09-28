//
//  YBPasterImageVC.h
//  testPasterImage
//
//  Created by 王迎博 on 16/9/5.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>


#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
/**传给上个页面图片的block*/
typedef void(^PasterBlock)(UIImage *image);

@interface YBPasterImageVC : UIViewController
/**传数据的block*/
@property (nonatomic, copy) PasterBlock block;
/**从上页带回来的原始image*/
@property (nonatomic, strong) UIImage *originalImage;
@end
