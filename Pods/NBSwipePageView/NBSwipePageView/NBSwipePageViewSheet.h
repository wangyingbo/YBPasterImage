//
//  NBSwipePageSheetView.h
//  NBSwipePageView
//
//  Created by 徐 哲 on 4/25/12.
//  Copyright (c) 2012 ラクラクテクノロジーズ株式会社 XUZHE.COM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NBSwipePageViewSheetEditingStyleNone,
    NBSwipePageViewSheetEditingStyleDelete,
    NBSwipePageViewSheetEditingStyleInsert
} NBSwipePageViewSheetEditingStyle;

@interface NBSwipePageViewSheet : UIView

@property (readonly, strong, nonatomic) UIView *contentView;
@property (readonly, strong, nonatomic) NSString *reuseIdentifier;
@property (strong, nonatomic) UIView *backgroundView;
@property (assign, nonatomic) CGFloat margin;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)prepareForReuse;

@end
