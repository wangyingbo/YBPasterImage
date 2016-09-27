//
//  NBSwipePageSheetView.m
//  NBSwipePageView
//
//  Created by 徐 哲 on 4/25/12.
//  Copyright (c) 2012 ラクラクテクノロジーズ株式会社 XUZHE.COM. All rights reserved.
//

#import "NBSwipePageViewSheet.h"

@implementation NBSwipePageViewSheet
@synthesize contentView = _contentView;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize backgroundView = _backgroundView;
@synthesize margin = _margin;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _reuseIdentifier = reuseIdentifier;
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.backgroundColor = [UIColor clearColor];    // set default color to clear color
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_backgroundView) {
        [_backgroundView removeFromSuperview];
    }
    _backgroundView = backgroundView;
    if (_backgroundView) {
        [self insertSubview:_backgroundView atIndex:0];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)prepareForReuse {
    _margin = 0.0f;
    self.transform = CGAffineTransformIdentity;
}

@end
