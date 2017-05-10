//
//  NBSwipePageView.h
//  NBSwipePageView
//
//  Created by 徐 哲 on 4/25/12.
//  Copyright (c) 2012 ラクラクテクノロジーズ株式会社 XUZHE.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NBSwipePageViewSheet.h"

typedef enum {
    NBSwipePageViewPageAnimationFade,
    NBSwipePageViewPageAnimationRight,           // slide in from right (or out to right)
    NBSwipePageViewPageAnimationLeft,
    NBSwipePageViewPageAnimationTop,
    NBSwipePageViewPageAnimationBottom,
    NBSwipePageViewPageAnimationNone,            // 
    NBSwipePageViewPageAnimationMiddle,          // attempts to keep cell centered in the space it will/did occupy
    NBSwipePageViewPageAnimationAutomatic = 100  // chooses an appropriate animation style for you
} NBSwipePageViewPageAnimation;

typedef enum {
    NBSwipePageViewModePageSize = 0,
    NBSwipePageViewModeFullSize = 1,
} NBSwipePageViewMode;

@protocol NBSwipePageViewDelegate;
@protocol NBSwipePageViewDataSource;

@interface NBSwipePageView : UIView

@property (unsafe_unretained, nonatomic) IBOutlet id<NBSwipePageViewDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet id<NBSwipePageViewDataSource> dataSource;

@property (readonly, nonatomic) NSUInteger currentPageIndex;
@property (readonly, nonatomic) BOOL isAnimating;
@property (readonly, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGSize scaleScrollView;
@property (assign, nonatomic) NBSwipePageViewMode pageViewMode;
@property (assign, nonatomic) BOOL allowsSelection;
@property (assign, nonatomic) BOOL disableScrollInFullSizeMode;
@property (strong, nonatomic) UIView *pageHeaderView;
@property (strong, nonatomic) UIView *pageTailView;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *pageTitleView;
@property (strong, nonatomic) void (^visibleViewEffectBlock)(id obj, NSUInteger idx, BOOL *stop);
@property (readonly, nonatomic) NSArray *visiblePages;

// UIScrollViews's property
@property (assign, nonatomic) BOOL delaysContentTouches;
@property (assign, nonatomic) UIEdgeInsets contentInset;
@property (assign, nonatomic) CGPoint contentOffset;
@property (assign, nonatomic) CGSize contentSize;
@property (assign, nonatomic) BOOL pagingEnabled;
@property (assign, nonatomic) BOOL scrollEnabled;
@property (readonly, assign, nonatomic) BOOL dragging;
@property (readonly, assign, nonatomic) BOOL tracking;
@property (readonly, assign, nonatomic) BOOL decelerating;

// Reload all pages. Always call this method after Data Source is changed.
- (NBSwipePageViewSheet *)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier;
- (void)reloadData;
- (void)scrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (NBSwipePageViewSheet *)swipePageViewSheetAtIndex:(NSUInteger)index;
- (void)setPageViewMode:(NBSwipePageViewMode)pageViewMode animated:(BOOL)animated;
- (BOOL)selectPageAtIndex:(NSUInteger)index animated:(BOOL)animated scrollToMiddle:(BOOL)scrollToMiddle;
- (BOOL)deselectPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

// Pulished methods for fast offset and index convert
- (NSUInteger)pageIndexOfCurrentOffset;
- (CGPoint)contentOffsetOfIndex:(NSUInteger)index;

// TODO: Edit the page view
- (void)beginUpdates;
- (void)endUpdates;
- (void)insertPagesAtIndexes:(NSIndexSet *)indexes withPageAnimation:(NBSwipePageViewPageAnimation)animated;
- (void)deletePagesAtIndexes:(NSIndexSet *)indexes withPageAnimation:(NBSwipePageViewPageAnimation)animated;
- (void)movePageAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
@end

@protocol NBSwipePageViewDelegate <NSObject, UIScrollViewDelegate>
@optional
// This delegate will be called after the user stoped the scroll.
// The index should always equal to currentPage index.
// The animated is YES if the page is scrolled by user or by scrollToPageAtIndex:animated:YES.
- (void)swipePageView:(NBSwipePageView *)swipePageView didScrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

// This delegate will be called when the user starts to scroll.
// The index is depend on the direction of user's swipe. If user is trying to swipe to the left page of the first page
// or the right page of the last page, the index will be equal to currentPage index.
// The animated is YES if the page is scrolled by user or by scrollToPageAtIndex:animated:YES.
- (void)swipePageView:(NBSwipePageView *)swipePageView willScrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

// This delegate will be called after the user scrolled back to the page which just started the scroll.
- (void)swipePageView:(NBSwipePageView *)swipePageView didCancelScrollFromPageAtIndex:(NSUInteger)index;

- (CGFloat)scaleOfSmallViewModeForSwipePageView:(NBSwipePageView *)swipePageView;  // default is 60%

- (NSUInteger)swipePageView:(NBSwipePageView *)swipePageView willSelectPageAtIndex:(NSUInteger)index;
- (void)swipePageView:(NBSwipePageView *)swipePageView didSelectPageAtIndex:(NSUInteger)index;
- (NSUInteger)swipePageView:(NBSwipePageView *)swipePageView willDeselectPageAtIndex:(NSUInteger)index;
- (void)swipePageView:(NBSwipePageView *)swipePageView didDeselectPageAtIndex:(NSUInteger)index;

// TODO: Action Menu Support
- (BOOL)swipePageView:(NBSwipePageView *)swipePageView shouldShowMenuForPageAtIndex:(NSUInteger)index;
- (BOOL)swipePageView:(NBSwipePageView *)swipePageView canPerformAction:(SEL)action forPageAtIndex:(NSUInteger)index withSender:(id)sender;
- (void)swipePageView:(NBSwipePageView *)swipePageView performAction:(SEL)action forPageAtIndex:(NSUInteger)index withSender:(id)sender;

// TODO: Editing Page View Support
- (void)swipePageView:(NBSwipePageView *)swipePageView willBeginEditingPageAtIndex:(NSUInteger)index;
- (void)swipePageView:(NBSwipePageView *)swipePageView didEndEditingPageAtIndex:(NSUInteger)index;
- (void)swipePageView:(NBSwipePageView *)swipePageView editingStyleForPageAtIndex:(NSUInteger)index;

@end

@protocol NBSwipePageViewDataSource <NSObject>
@required
// You should use this data source to tell me how many pages in the swipe page view.
- (NSUInteger)numberOfPagesInSwipePageView:(NBSwipePageView *)swipePageView;
// Give me a sheet for the page at index.
- (NBSwipePageViewSheet *)swipePageView:(NBSwipePageView *)swipePageView sheetForPageAtIndex:(NSUInteger)index;

@optional
// TODO: Editing page views
- (BOOL)swipePageView:(NBSwipePageView *)swipePageView canEditPageAtIndex:(NSUInteger)index;
- (void)swipePageView:(NBSwipePageView *)swipePageView commitEditingStyle:(NBSwipePageViewSheetEditingStyle)editingStyle forPagetAtIndex:(NSUInteger)index;

// TODO: Reording page views
- (BOOL)swipePageView:(NBSwipePageView *)swipePageView canMovePageAtIndex:(NSUInteger)index;
- (void)swipePageView:(NBSwipePageView *)swipePageView movePageAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
