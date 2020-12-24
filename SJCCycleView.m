//
//  SJCCycleView.m
//  PingDD
//
//  Created by 时光与你 on 2018/9/7.
//  Copyright © 2018年 Yehwang. All rights reserved.
//

#import "SJCCycleView.h"
@interface SJCCycleView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView *mainView;
@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger numberOfItems;
@end
@implementation SJCCycleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureProperty];
        [self addCollectionView];
        [self addPageControl];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureProperty];
        [self addCollectionView];
        [self addPageControl];
    }
    return self;
}

- (void)configureProperty{
    _autoScrollInterval = 3.0;
    _isInfiniteLoop = YES;
    _showPageControl = YES;
    
}

- (void)addCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout = flowLayout;
    
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    mainView.dataSource = self;
    mainView.delegate = self;
    mainView.scrollsToTop = NO;
    [self addSubview:mainView];
    _mainView = mainView;
}

- (void)addPageControl{
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
    pageControl.pageIndicatorTintColor = self.pageDotColor;
    pageControl.userInteractionEnabled = NO;
    pageControl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.618, 0.618);
    [self addSubview:pageControl];
    _pageControl = pageControl;
}

- (void)reloadData{
    [_mainView reloadData];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _flowLayout.itemSize = self.frame.size;
    _mainView.frame = self.bounds;
    _pageControl.frame = CGRectMake(0, self.bounds.size.height-20, self.bounds.size.width, 20);
    if (_mainView.contentOffset.x == 0 &&  _numberOfItems) {
        int targetIndex = 0;
        if (self.isInfiniteLoop) {
            targetIndex = _numberOfItems * 0.5;
        }else{
            targetIndex = 0;
        }
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier {
    [_mainView registerClass:Class forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [_mainView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    UICollectionViewCell *cell = [_mainView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [_dataSource cycleView:self cellForItemAtIndex:indexPath.row];
    NSAssert(NO, @"pagerView cellForItemAtIndex: is nil!");
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate&&[_delegate respondsToSelector:@selector(cycleView:didSelectedItemCell:atIndex:)]) {
        [_delegate cycleView:self didSelectedItemCell:cell atIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _pageControl.currentPage = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.autoScrollInterval) {
        [self removeTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.autoScrollInterval) {
        [self addTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:self.mainView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.delegate respondsToSelector:@selector(cycleView:didScrollToIndex:)]) {
        [self.delegate cycleView:self didScrollToIndex:indexOnPageControl];
    }
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index{
    return (int)index % [_dataSource numberOfItemsInCycleView:self];
}

- (void)setDelegate:(id<SJCCycleViewDelegate>)delegate{
    _delegate = delegate;
}

- (void)setDataSource:(id<SJCCycleViewDataSource>)dataSource{
    _dataSource = dataSource;
    if ([_dataSource numberOfItemsInCycleView:self] < 2) {
        self.isInfiniteLoop = NO;
        _pageControl.hidden = YES;
    }else{
        [self setIsInfiniteLoop:self.isInfiniteLoop];
        _pageControl.hidden = NO;
    }
    _pageControl.numberOfPages = [_dataSource numberOfItemsInCycleView:self];
    _numberOfItems = _isInfiniteLoop ? [_dataSource numberOfItemsInCycleView:self] * 100 : [_dataSource numberOfItemsInCycleView:self];
    
    if ([_dataSource numberOfItemsInCycleView:self] > 1) {
        self.mainView.scrollEnabled = YES;
        [self setAutoScrollInterval:self.autoScrollInterval];
    } else {
        self.mainView.scrollEnabled = NO;
        [self removeTimer];
    }
}

- (void)setIsInfiniteLoop:(BOOL)isInfiniteLoop{
    _isInfiniteLoop = isInfiniteLoop;
}

- (void)setAutoScrollInterval:(CGFloat)autoScrollInterval{
    _autoScrollInterval = autoScrollInterval;
    [self removeTimer];
    if (autoScrollInterval > 0 && self.superview) {
        [self addTimer];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection{
    _scrollDirection = scrollDirection;
    _flowLayout.scrollDirection = scrollDirection;
}

- (void)setShowPageControl:(BOOL)showPageControl{
    _showPageControl = showPageControl;
    _pageControl.hidden = !showPageControl;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor{
    _currentPageDotColor = currentPageDotColor;
    _pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    
}

- (void)setPageDotColor:(UIColor *)pageDotColor{
    _pageDotColor = pageDotColor;
    _pageControl.pageIndicatorTintColor = pageDotColor;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self removeTimer];
    }else {
        [self removeTimer];
        if (_autoScrollInterval > 0&&_numberOfItems > 1) {
            [self addTimer];
        }
    }
}

- (void)addTimer {
    if (_timer) {
        return;
    }
    _timer = [NSTimer timerWithTimeInterval:_autoScrollInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll{
    if (!self.superview || !self.window || _numberOfItems == 0 || self.tracking) {
        return;
    }
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}

- (BOOL)tracking {
    return _mainView.tracking;
}

- (void)scrollToIndex:(int)targetIndex{
    if (targetIndex >= _numberOfItems) {
        if (self.isInfiniteLoop) {
            targetIndex = _numberOfItems * 0.5;
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (int)currentIndex{
    if (_mainView.frame.size.width == 0 || _mainView.frame.size.height == 0) {
        return 0;
    }
    
    int index = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_mainView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    } else {
        index = (_mainView.contentOffset.y + _flowLayout.itemSize.height * 0.5) / _flowLayout.itemSize.height;
    }
    
    return MAX(0, index);
}

- (void)makeScrollViewScrollToIndex:(NSInteger)index{
    if (!self.autoScrollInterval) {
        [self removeTimer];
    }
    if (0 == _numberOfItems) return;
    
    [self scrollToIndex:(int)(_numberOfItems * 0.5 + index)];
    
    if (self.autoScrollInterval) {
        [self addTimer];
    }
}

- (void)disableScrollGesture {
    self.mainView.canCancelContentTouches = NO;
    for (UIGestureRecognizer *gesture in self.mainView.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.mainView removeGestureRecognizer:gesture];
        }
    }
}

- (void)dealloc {
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}
@end

