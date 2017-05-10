//
//  NBSwipePageView.m
//  NBSwipePageView
//
//  Created by 徐 哲 on 4/25/12.
//  Copyright (c) 2012 ラクラクテクノロジーズ株式会社 XUZHE.COM. All rights reserved.
//

#import "NBSwipePageView.h"

#define kMaxVisiblePageLength           3

@interface NBSwipePageTouchView : UIView

@property (unsafe_unretained, nonatomic) UIView *touchHandlerView;
@end

@implementation NBSwipePageTouchView

- (void)initCodes {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor clearColor];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initCodes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initCodes];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCodes];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	if (_touchHandlerView && [self pointInside:point withEvent:event]) {
        UIView *test = [_touchHandlerView hitTest:[self convertPoint:point toView:_touchHandlerView] withEvent:event];
		return test == nil ? _touchHandlerView : test;
	}
	return nil;
}

@end

// ======================= NBSwipePageView =======================
@interface NBSwipePageView (PrivateMethod) <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation NBSwipePageView {
    NBSwipePageTouchView *_touchView;
    NBSwipePageViewSheet *_currentPage;
    NSMutableArray *_visiblePages;
    NSMutableDictionary *_reusablePages;
    NSUInteger _cachedNumberOfPages;
    NSRange _visibleRange;
    BOOL _isPendingScrolledPageUpdateNotification;
    CGFloat _cachedScaleRate;
    NSUInteger _selectedPageIndex;
}

#pragma mark - Init Codes
- (void)initCodes {
    // init settings
    _currentPageIndex = NSNotFound;
    _selectedPageIndex = NSNotFound;
    _allowsSelection = NO;
    _disableScrollInFullSizeMode = NO;  // defult is do NOT disable scroll in full size mode
    _isPendingScrolledPageUpdateNotification = NO;
    
    _scaleScrollView = CGSizeMake(1.0f, 1.0f);
    
    // init views
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _scrollView.clipsToBounds = NO;
    _scrollView.delaysContentTouches = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.canCancelContentTouches = YES;
    [self addSubview:_scrollView];
    
    [self setPageViewMode:NBSwipePageViewModePageSize]; // default mode is page size
    
    // set tap gesture recognizer for page selection
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[_scrollView addGestureRecognizer:tapRecognizer];
	tapRecognizer.delegate = self;
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_scrollView addGestureRecognizer:longPressRecognizer];
    longPressRecognizer.delegate = self;

    // init caches
    _cachedNumberOfPages = 0;
    _visiblePages = [NSMutableArray arrayWithCapacity:4];
    _reusablePages = [NSMutableDictionary dictionary];
    
    _visibleRange.location = 0;
    _visibleRange.length = 0;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initCodes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initCodes];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCodes];
    }
    return self;
}

//- (void)dealloc {
//    NSLog(@"Just for release check.");
//}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateContentSize];
    [self relayoutVisiblePages];
}

#pragma mark - Delegate Sender
- (void)delegateDidScrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:didScrollToPageAtIndex:animated:)]) {
        [_delegate swipePageView:self didScrollToPageAtIndex:index animated:animated];
    }
}

- (void)delegateWillScrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:willScrollToPageAtIndex:animated:)]) {
        [_delegate swipePageView:self willScrollToPageAtIndex:index animated:animated];
    }
}

- (void)delegateDidCancelScrollFromPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:didCancelScrollFromPageAtIndex:)]) {
        [_delegate swipePageView:self didCancelScrollFromPageAtIndex:index];
    }
}

- (CGFloat)delegateScaleOfSmallViewMode {
    if (_delegate && [_delegate respondsToSelector:@selector(scaleOfSmallViewModeForSwipePageView:)]) {
        return [_delegate scaleOfSmallViewModeForSwipePageView:self];
    }
    return 0.6; // default is 60%
}

- (NSUInteger)delegateWillSelectPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:willSelectPageAtIndex:)]) {
        return [_delegate swipePageView:self willSelectPageAtIndex:index];
    }
    return index;
}

- (void)delegateDidSelectPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:didSelectPageAtIndex:)]) {
        [_delegate swipePageView:self didSelectPageAtIndex:index];
    }
}

- (NSUInteger)delegateWillDeselectPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:willDeselectPageAtIndex:)]) {
        [_delegate swipePageView:self willDeselectPageAtIndex:index];
    }
    return index;
}

- (void)delegateDidDeselectPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:didDeselectPageAtIndex:)]) {
        [_delegate swipePageView:self didDeselectPageAtIndex:index];
    }
}

// TODO: Action Menu Support
- (BOOL)delegateShouldShowMenuForPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:shouldShowMenuForPageAtIndex:)]) {
        return [_delegate swipePageView:self shouldShowMenuForPageAtIndex:index];
    }
    return NO;
}

- (BOOL)delegateCanPerformAction:(SEL)action forPageAtIndex:(NSUInteger)index withSender:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:canPerformAction:forPageAtIndex:withSender:)]) {
        return [_delegate swipePageView:self canPerformAction:action forPageAtIndex:index withSender:sender];
    }
    return NO;
}

- (void)delegatePerformAction:(SEL)action forPageAtIndex:(NSUInteger)index withSender:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:performAction:forPageAtIndex:withSender:)]) {
        [_delegate swipePageView:self performAction:action forPageAtIndex:index withSender:sender];
    }
}

// TODO: Editing Page View Support
- (void)delegateWillBeginEditingPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:willBeginEditingPageAtIndex:)]) {
        [_delegate swipePageView:self willBeginEditingPageAtIndex:index];
    }
}

- (void)delegateDidEndEditingPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:didEndEditingPageAtIndex:)]) {
        [_delegate swipePageView:self didEndEditingPageAtIndex:index];
    }
}

- (void)delegateEditingStyleForPageAtIndex:(NSUInteger)index {
    if (_delegate && [_delegate respondsToSelector:@selector(swipePageView:editingStyleForPageAtIndex:)]) {
        [_delegate swipePageView:self editingStyleForPageAtIndex:index];
    }
}

#pragma mark - Datasource Sender
// Required Datasource
- (NSUInteger)dataSourceLoadNumberOfPages {
    NSUInteger pages = [_dataSource numberOfPagesInSwipePageView:self];
    if (_cachedNumberOfPages == pages) {
        return pages;
    }
    _cachedNumberOfPages = pages;
    [self updateContentSize];
    return pages;
}

- (NBSwipePageViewSheet *)dataSourceSheetForPageAtIndex:(NSUInteger)index {
    NBSwipePageViewSheet *sheet = [_dataSource swipePageView:self sheetForPageAtIndex:index];
    NSAssert(sheet != nil, @"The sheet for page at index: %d must not be nil", index);
    return sheet;
}

// Option Datasource
// TODO: Editing page views
- (BOOL)dataSourceCanEditPageAtIndex:(NSUInteger)index {
    if (_dataSource && [_dataSource respondsToSelector:@selector(swipePageView:canEditPageAtIndex:)]) {
        return [_dataSource swipePageView:self canEditPageAtIndex:index];
    }
    return NO;
}

- (void)dataSourceCommitEditingStyle:(NBSwipePageViewSheetEditingStyle)editingStyle forPagetAtIndex:(NSUInteger)index {
    if (_dataSource && [_dataSource respondsToSelector:@selector(swipePageView:commitEditingStyle:forPagetAtIndex:)]) {
        [_dataSource swipePageView:self commitEditingStyle:editingStyle forPagetAtIndex:index];
    }
}

// TODO: Reording page views
- (BOOL)dataSourceCanMovePageAtIndex:(NSUInteger)index {
    if (_dataSource && [_dataSource respondsToSelector:@selector(swipePageView:canMovePageAtIndex:)]) {
        return [_dataSource swipePageView:self canMovePageAtIndex:index];
    }
    return NO;
}

- (void)dataSourceMovePageAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (_dataSource && [_dataSource respondsToSelector:@selector(swipePageView:movePageAtIndex:toIndex:)]) {
        [_dataSource swipePageView:self movePageAtIndex:fromIndex toIndex:toIndex];
    }
}

#pragma mark - Private Logic Methods
- (void)updateContentSize {
    _scrollView.contentSize = CGSizeMake((CGFloat)_cachedNumberOfPages * _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    
    if (_pageTailView) {
        CGRect frame = _pageTailView.frame;
        frame.origin.x = _scrollView.contentSize.width + self.bounds.size.width - CGRectGetMaxX(_scrollView.frame);
        _pageTailView.frame = frame;
    }
    if (_pageHeaderView) {
        CGRect frame = _pageHeaderView.frame;
        frame.origin.x = -frame.size.width - CGRectGetMinX(_scrollView.frame);
        _pageHeaderView.frame = frame;
    }
}

- (void)resizeScrollView {
    CGRect frame = _scrollView.frame;
    CGFloat width = self.bounds.size.width * _scaleScrollView.width;
    width += (self.bounds.size.width - width) * 0.25f;
    frame.size.width = ceilf(width);
    frame.size.height = ceilf(self.bounds.size.height * _scaleScrollView.height);
    frame.origin.x = floorf((self.bounds.size.width - frame.size.width) * 0.5);
    frame.origin.y = floorf((self.bounds.size.height - frame.size.height) * 0.5);
    _scrollView.frame = frame;
    [self updateContentSize];
    [self relayoutVisiblePages];
}

- (void)setFrameForPage:(NBSwipePageViewSheet *)page atIndex:(NSInteger)index {
    page.transform = CGAffineTransformMakeScale(_cachedScaleRate, _cachedScaleRate);
	CGFloat contentOffset = (CGFloat)index * _scrollView.frame.size.width;
	CGFloat margin = floorf((_scrollView.frame.size.width - page.frame.size.width) * 0.5f); 
	CGRect frame = page.frame;
	frame.origin.x = floorf(contentOffset + margin);
	page.frame = frame;
    page.margin = margin;
}

- (void)relayoutVisiblePages {
    for (NSUInteger i = 0; i < [_visiblePages count]; i++) {
        NBSwipePageViewSheet *sheet = _visiblePages[i];
        NSUInteger index = _visibleRange.location + i;
        if (index >= _cachedNumberOfPages) {
            continue;
        }
        [self setFrameForPage:sheet atIndex:index];
    }
}

- (void)shiftPage:(UIView*)page withOffset:(CGFloat)offset {
    CGRect frame = page.frame;
    frame.origin.x += offset;
    page.frame = frame;
}

- (NBSwipePageViewSheet *)loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex {
	NBSwipePageViewSheet *visiblePage = [self dataSourceSheetForPageAtIndex:index];
	
	// add the page to the visible pages array
	[_visiblePages insertObject:visiblePage atIndex:visibleIndex];
    
    return visiblePage;
}

- (CGPoint)contentOffsetOfIndex:(NSUInteger)index {
    return CGPointMake(_scrollView.bounds.size.width * (CGFloat)index, 0.0f);
}

- (NSUInteger)pageIndexOfCurrentOffset {
    CGFloat pageWidth = _scrollView.bounds.size.width;
    return floor((_scrollView.contentOffset.x - pageWidth * 0.5f) / pageWidth) + 1.0f;
}

- (void)preparePage:(NBSwipePageViewSheet *)page forMode:(NBSwipePageViewMode)mode {
    // When a page is presented in NBSwipePageViewMode mode, it is scaled up and is moved to a different superview. 
    // As it captures the full screen, it may be cropped to fit inside its new superview's frame. 
    // So when moving it back to NBSwipePageViewMode, we restore the page's proportions to prepare it to Deck mode.  
	if (mode == NBSwipePageViewModePageSize && 
        CGAffineTransformEqualToTransform(page.transform, CGAffineTransformIdentity)) {
        // TODO: 
//        page.frame = page.identityFrame;
	}
}

// add a page to the scroll view at a given index. No adjustments are made to existing pages offsets. 
- (void)addPageToScrollView:(NBSwipePageViewSheet *)page atIndex:(NSInteger)index {
    // inserting a page into the scroll view is in HGPageScrollViewModeDeck by definition (the scroll is the "deck")
    [self preparePage:page forMode:NBSwipePageViewModePageSize];
    
	// configure the page frame
    [self setFrameForPage:page atIndex:index];
    
    // add the page to the scroller
	[_scrollView insertSubview:page atIndex:0];
}

- (void)addToReusablePages:(NBSwipePageViewSheet *)page {
    NSMutableSet *set = _reusablePages[page.reuseIdentifier];
    if (set) {
        // if already have one reusable page, do not add another one.
        if ([set count] == 0) {
            [set addObject:page];
        }
    } else {
        set = [NSMutableSet setWithObject:page];
        _reusablePages[page.reuseIdentifier] = set;
    }
}

// Update Visible Pages
- (void)updateVisiblePages:(BOOL)force {
    NSRange lastVisibleRange = _visibleRange;
    [self updateVisibleRange:[self pageIndexOfCurrentOffset]];
    
    if (NSEqualRanges(lastVisibleRange, _visibleRange) && !force) {
        return;
    }
    
    BOOL initVisiblePages = ([_visiblePages count] == 0);
    if (!initVisiblePages) {
        NSUInteger maxRange = NSMaxRange(lastVisibleRange);
        for (NSUInteger i = maxRange - 1; i < maxRange && i >= lastVisibleRange.location; i--) {
            if (!NSLocationInRange(i, _visibleRange)) {
                NSUInteger ii = i - lastVisibleRange.location;
                NBSwipePageViewSheet *page = _visiblePages[ii];
                [page removeFromSuperview];
                [self addToReusablePages:page];
                [_visiblePages removeObjectAtIndex:ii];
            }
        }
    }
    for (NSUInteger i = _visibleRange.location; i < NSMaxRange(_visibleRange); i++) {
        if (initVisiblePages || !NSLocationInRange(i, lastVisibleRange)) {
            NBSwipePageViewSheet *page = [self loadPageAtIndex:i insertIntoVisibleIndex:i - _visibleRange.location];
            // add the page to the scroll view (to make it actually visible)
            [self addPageToScrollView:page atIndex:i];
        }
    }
}

- (void)updateScrolledPageIndex:(NSUInteger)index animated:(BOOL)animated {
    NBSwipePageViewSheet *page = [self swipePageViewSheetAtIndex:index];
    if (page) {
        // notify delegate
        [self delegateWillScrollToPageAtIndex:index animated:animated];   // TODO:
                
        // set the page selector (page control)
        _currentPageIndex = index;
        
        // set selected page
        _currentPage = page;
        
        //	NSLog(@"selectedPage: 0x%x (index %d)", page, index );
        
        if (_scrollView.dragging || _scrollView.decelerating) {
            _isPendingScrolledPageUpdateNotification = YES;
        } else {
            _isPendingScrolledPageUpdateNotification = NO;
            [self delegateDidScrollToPageAtIndex:_currentPageIndex animated:animated];
        }
    }
}

- (NSUInteger)indexForVisiblePage:(NBSwipePageViewSheet *)page {
	NSUInteger index = [_visiblePages indexOfObject:page];
	if (index != NSNotFound) {
        return _visibleRange.location + index;
    }
    return NSNotFound;
}

#pragma mark - Set Views
- (void)setBackgroundView:(UIView *)backgroundView {
    if ([backgroundView isEqual:_backgroundView]) {
        return;
    }
    if (_backgroundView) {
        [_backgroundView removeFromSuperview];
    }
    _backgroundView = backgroundView;
    if (backgroundView) {
        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;   // should always autoresize background view
        [self insertSubview:backgroundView atIndex:0];
    }
}

- (void)setPageHeaderView:(UIView *)pageHeaderView {
    if ([pageHeaderView isEqual:_pageHeaderView]) {
        return;
    }
    if (_pageHeaderView) {
        [_pageHeaderView removeFromSuperview];
    }
    _pageHeaderView = pageHeaderView;
    if (pageHeaderView) {
        [_scrollView addSubview:pageHeaderView];
    }
}

- (void)setPageTailView:(UIView *)pageTailView {
    if ([pageTailView isEqual:_pageTailView]) {
        return;
    }
    if (_pageTailView) {
        [_pageTailView removeFromSuperview];
    }
    _pageTailView = pageTailView;
    if (pageTailView) {
        [_scrollView addSubview:pageTailView];
    }
}

- (void)setPageTitleView:(UIView *)pageTitleView {
    if ([pageTitleView isEqual:_pageTitleView]) {
        return;
    }
    if (_pageTitleView) {
        [_pageTitleView removeFromSuperview];
    }
    _pageTitleView = pageTitleView;
    if (pageTitleView) {
        [self addSubview:pageTitleView];
    }
}

#pragma mark - Set Propertys
- (void)setPageViewMode:(NBSwipePageViewMode)pageViewMode {
    [self setPageViewMode:pageViewMode animated:NO];
}

#pragma mark - Public Methods
- (NBSwipePageViewSheet *)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier {
    NSMutableSet *reusableSet = _reusablePages[reuseIdentifier];
    NBSwipePageViewSheet *reusableSheet = [reusableSet anyObject];
    if (reusableSheet) {
        [reusableSheet prepareForReuse];
        [reusableSet removeObject:reusableSheet];
        return reusableSheet;
    }
    return nil;
}

- (void)updateVisibleRange:(NSUInteger)currentIndex {
    if (currentIndex >= NSNotFound || currentIndex == 0) {
        _currentPageIndex = 0;
        _visibleRange.location = 0;
        _visibleRange.length = MIN(kMaxVisiblePageLength - 1, _cachedNumberOfPages);
    } else if (currentIndex >= _cachedNumberOfPages) {
        _currentPageIndex = _cachedNumberOfPages - 1;
        _visibleRange.location = MIN(_currentPageIndex - 1, _cachedNumberOfPages - 1);
        _visibleRange.length = MIN(kMaxVisiblePageLength - 1, _cachedNumberOfPages);
    } else {
        _visibleRange.location = currentIndex - 1;
        _visibleRange.length = MIN(MIN(kMaxVisiblePageLength, _cachedNumberOfPages), _cachedNumberOfPages - _visibleRange.location);
    }
}

- (void)setScaleScrollView:(CGSize)scaleScrollView {
    if (!CGSizeEqualToSize(scaleScrollView, _scaleScrollView)) {
        _scaleScrollView = scaleScrollView;
        [self resizeScrollView];
    }
}

- (void)reloadData {
    [_reusablePages removeAllObjects];
    [_visiblePages removeAllObjects];
    [[_scrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        *stop = NO;
        if ([obj isEqual:_pageTailView] || [obj isEqual:_pageHeaderView]) {
            return ;
        }
        [obj removeFromSuperview];
    }];

    if (_pageViewMode == NBSwipePageViewModePageSize) {
        _cachedScaleRate = [self delegateScaleOfSmallViewMode];
    } else {
        _cachedScaleRate = 1.0f;
    }
    [self resizeScrollView];

    [self dataSourceLoadNumberOfPages];
    _selectedPageIndex = NSNotFound;
    if (_cachedNumberOfPages == 0 || _cachedNumberOfPages >= NSNotFound) {
        _currentPage = nil;
        _currentPageIndex = NSNotFound;
        return;
    }
    
    // this will load any additional views which become visible  
    [self updateVisiblePages:YES];
    _currentPage = [self swipePageViewSheetAtIndex:_currentPageIndex];
    
    // reloading the data implicitely resets the viewMode to UIPageScrollViewModeDeck.
    // here we restore the view mode in case this is not the first time reloadData is called (i.e. if there if a _selectedPage).   
//    if (_selectedPage && _viewMode==HGPageScrollViewModePage) { 
//        _viewMode = HGPageScrollViewModeDeck;
//        [self setViewMode:HGPageScrollViewModePage animated:NO];
//    }
    if (_pageViewMode == NBSwipePageViewModePageSize && _visibleViewEffectBlock) {
        [_visiblePages enumerateObjectsUsingBlock:_visibleViewEffectBlock];
    }
}

- (void)scrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    _isAnimating = animated;
    [_scrollView setContentOffset:[self contentOffsetOfIndex:index] animated:animated];
    if (!animated) {
        // do not call this method when animated,
        // because it will be called in UIScrollViewDelegate.
        [self updateScrolledPageIndex:index animated:animated];
    }
}

- (NBSwipePageViewSheet *)swipePageViewSheetAtIndex:(NSUInteger)index {
    if (index >= _cachedNumberOfPages) {
        // Out of bounds
        return nil;
    }
    if (NSLocationInRange(index, _visibleRange)) {
        return _visiblePages[index - _visibleRange.location];
    }
    return [self dataSourceSheetForPageAtIndex:index];
}

- (void)setPageViewMode:(NBSwipePageViewMode)pageViewMode animated:(BOOL)animated {
    _pageViewMode = pageViewMode;
    if (pageViewMode == NBSwipePageViewModeFullSize) {
        if (_touchView) {
            [_touchView removeFromSuperview];
            _touchView = nil;
        }
    } else {
        if (!_touchView) {
            _touchView = [[NBSwipePageTouchView alloc] initWithFrame:self.bounds];
            _touchView.touchHandlerView = _scrollView;
            _touchView.autoresizingMask = _scrollView.autoresizingMask;
            [self addSubview:_touchView];
        }
    }
    // TODO: add animated support
}

- (BOOL)selectPageAtIndex:(NSUInteger)index animated:(BOOL)animated scrollToMiddle:(BOOL)scrollToMiddle {
    if (![self deselectPageAtIndex:_selectedPageIndex animated:animated]) {
        return NO;
    }
    NSUInteger shouldSelectIndex = [self delegateWillSelectPageAtIndex:index];
    if (shouldSelectIndex >= NSNotFound) {
        return NO;
    } else if (shouldSelectIndex != _currentPageIndex && scrollToMiddle) {
        [self delegateDidSelectPageAtIndex:shouldSelectIndex];  // should be called before currentIndex changed by scrollToPageAtIndex:
        [self scrollToPageAtIndex:shouldSelectIndex animated:animated];
    } else {
        [self delegateDidSelectPageAtIndex:shouldSelectIndex];
    }
    _selectedPageIndex = shouldSelectIndex;
    return YES;
}

- (BOOL)deselectPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    if (index >= NSNotFound) {
        return YES;
    }
    NSUInteger shouldDeselectIndex = [self delegateWillDeselectPageAtIndex:_selectedPageIndex];
    if (shouldDeselectIndex >= NSNotFound) {
        return NO;
    }
    [self delegateDidDeselectPageAtIndex:_selectedPageIndex];
    _selectedPageIndex = NSNotFound;
    return YES;
}

// TODO: Edit the page view
- (void)beginUpdates {
    
}

- (void)endUpdates {
    
}

- (void)insertPagesAtIndexes:(NSIndexSet *)indexes withPageAnimation:(NBSwipePageViewPageAnimation)animated {
    
}

- (void)deletePagesAtIndexes:(NSIndexSet *)indexes withPageAnimation:(NBSwipePageViewPageAnimation)animated {
    
}

- (void)movePageAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateVisiblePages:NO];
    
    if (_pageViewMode == NBSwipePageViewModePageSize && _visibleViewEffectBlock) {
        [_visiblePages enumerateObjectsUsingBlock:_visibleViewEffectBlock];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _isAnimating = NO;
    [self updateScrolledPageIndex:[self pageIndexOfCurrentOffset] animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateScrolledPageIndex:[self pageIndexOfCurrentOffset] animated:NO];
        if (_isPendingScrolledPageUpdateNotification) {
            _isPendingScrolledPageUpdateNotification = NO;
            [self delegateDidScrollToPageAtIndex:_currentPageIndex animated:NO];
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateScrolledPageIndex:[self pageIndexOfCurrentOffset] animated:YES];
    if (_isPendingScrolledPageUpdateNotification) {
        _isPendingScrolledPageUpdateNotification = NO;
        [self delegateDidScrollToPageAtIndex:_currentPageIndex animated:YES];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

#pragma make - Get or Set some propeties of UIScrollView
- (CGPoint)contentOffset {
    return _scrollView.contentOffset;
}

- (CGSize)contentSize {
    return _scrollView.contentSize;
}

- (BOOL)dragging {
    return _scrollView.dragging;
}

- (BOOL)tracking {
    return _scrollView.tracking;
}

- (BOOL)decelerating {
    return _scrollView.decelerating;
}

- (UIEdgeInsets)contentInset {
    return _scrollView.contentInset;
}

- (BOOL)pagingEnabled {
    return _scrollView.pagingEnabled;
}

- (BOOL)scrollEnabled {
    return _scrollView.scrollEnabled;
}

- (BOOL)delaysContentTouches {
    return _scrollView.delaysContentTouches;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _scrollView.contentInset = contentInset;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    _scrollView.contentOffset = contentOffset;
}

- (void)setContentSize:(CGSize)contentSize {
    _scrollView.contentSize = contentSize;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _scrollView.pagingEnabled = pagingEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollView.scrollEnabled = scrollEnabled;
}

- (void)setDelaysContentTouches:(BOOL)delaysContentTouches {
    _scrollView.delaysContentTouches = delaysContentTouches;
}

- (NSArray *)visiblePages {
    return [NSArray arrayWithArray:_visiblePages];
}

#pragma mark -
#pragma mark Handling Touches

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if (_pageViewMode == NBSwipePageViewModePageSize && !_scrollView.decelerating && !_scrollView.dragging && !_isAnimating) {
		return YES;	
	}
	return NO;	
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)recognizer  {
    if (_currentPageIndex >= NSNotFound) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self deselectPageAtIndex:_selectedPageIndex animated:YES];
    } else if (recognizer.state == UIGestureRecognizerStateRecognized) {
        for (NBSwipePageViewSheet *page in _visiblePages) {
            if ([page pointInside:[recognizer locationInView:page] withEvent:nil]) {
                [self selectPageAtIndex:[self indexForVisiblePage:page] animated:YES scrollToMiddle:YES];
                return;
            }
        }
    }
}

@end
