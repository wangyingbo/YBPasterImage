//
//  YBPasterImageVC.h
//  testPasterImage
//
//  Created by 王迎博 on 16/9/5.
//  Copyright © 2016年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YBWeak(selfName,weakSelf) __weak __typeof(selfName *)weakSelf = self
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
/**传给上个页面图片的block*/
typedef void(^PasterBlock)(UIImage *image);


@interface YBPasterImageVC : UIViewController
/**传数据的block*/
@property (nonatomic, copy) PasterBlock block;
/**从上页带回来的原始image*/
@property (nonatomic, strong) UIImage *originalImage;


/**
 *  初始化一个对象
 *
 *  @param name 名字
 *
 *  @return 自己
 */
- (instancetype)initWithName:(NSString *)name;


/**尽量不使用以下形式：
 @interface B : UIViewController
 @property (strong) NSString* name;
 @end
 //然后使用的时候这个样子：
 B* vc = [B new];
 vc.name = @"xx";
 [self.navigationController push:vc];
 */

@end
