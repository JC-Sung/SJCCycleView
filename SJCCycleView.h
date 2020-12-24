//
//  SJCCycleView.h
//  PingDD
//
//  Created by 时光与你 on 2018/9/7.
//  Copyright © 2018年 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJCCycleView;
@protocol SJCCycleViewDataSource <NSObject>

- (NSInteger)numberOfItemsInCycleView:(SJCCycleView *)CycleView;

- (__kindof UICollectionViewCell *)cycleView:(SJCCycleView *)cycleView cellForItemAtIndex:(NSInteger)index;

@end

@protocol SJCCycleViewDelegate <NSObject>

@optional

- (void)cycleView:(SJCCycleView *)cycleView didScrollToIndex:(NSInteger)toIndex;

- (void)cycleView:(SJCCycleView *)cycleView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index;

@end

@interface SJCCycleView : UIView

@property (nonatomic, weak, nullable) id<SJCCycleViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJCCycleViewDelegate> delegate;

@property (nonatomic, assign) BOOL isInfiniteLoop;

@property (nonatomic, assign) CGFloat autoScrollInterval;

@property (nonatomic, assign) BOOL showPageControl;

@property (nonatomic, strong) UIColor *currentPageDotColor;

@property (nonatomic, strong) UIColor *pageDotColor;

@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

- (void)makeScrollViewScrollToIndex:(NSInteger)index;

- (void)reloadData;

- (void)disableScrollGesture;

- (void)registerClass:(Class)Class forCellWithReuseIdentifier:(NSString *)identifier;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

NS_ASSUME_NONNULL_END
@end
