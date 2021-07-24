//
//  MJRefreshLeader.m
//  Mangadex
//
//  Created by John Rion on 2021/7/21.
//

#import <Foundation/Foundation.h>
#import "MJRefreshLeader.h"

@interface MJRefreshLeader ()

@property (nonatomic, assign) NSInteger lastRefreshCount;
@property (nonatomic, assign) CGFloat lastLeftDelta;

@end

@implementation MJRefreshLeader

+ (instancetype)leaderWithRefreshingBlock:(MJRefreshComponentAction)refreshingBlock {
    MJRefreshLeader *cmp = [self new];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}

+ (instancetype)leaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    MJRefreshLeader *cmp = [self new];
    [cmp setRefreshingTarget:target refreshingAction:action];
    return cmp;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    
    if (self.state == MJRefreshStateRefreshing) {
        return;
    }
    
    _scrollViewOriginalInset = self.scrollView.mj_inset;
    
    CGFloat currentOffsetX = self.scrollView.mj_offsetX;
    CGFloat happenOffsetX = [self happenOffsetX];
    if (currentOffsetX >= happenOffsetX) {
        return;
    }
    
    CGFloat pullingPercent = (-currentOffsetX) / self.mj_w;
    
    if (self.state == MJRefreshStateNoMoreData) {
        self.pullingPercent = pullingPercent;
        return;
    }
    
    if (self.scrollView.isDragging) {
        self.pullingPercent = pullingPercent;
        
        // 切换状态
        if (self.state == MJRefreshStateIdle && pullingPercent >= 1) {
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && pullingPercent < 1) {
            // 转为普通状态
            self.state = MJRefreshStateIdle;
        }
    } else if (self.state == MJRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    
    if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            [UIView animateWithDuration:self.slowAnimationDuration animations:^{
                !self.endRefreshingAnimationBeginAction ?: self.endRefreshingAnimationBeginAction();
                
                self.scrollView.mj_insetL += self.lastLeftDelta;
                if (self.isAutomaticallyChangeAlpha) {
                    self.alpha = 0;
                }
            } completion:^(BOOL finished) {
                self.pullingPercent = 0;
                !self.endRefreshingCompletionBlock ?: self.endRefreshingCompletionBlock();
            }];
        }
        
        if (oldState == MJRefreshStateRefreshing && self.scrollView.mj_totalDataCount != self.lastRefreshCount) {
            self.scrollView.mj_offsetX = self.scrollView.mj_offsetX;
        }
    } else if (state == MJRefreshStateRefreshing) {
        self.lastRefreshCount = self.scrollView.mj_totalDataCount;
        
        [UIView animateWithDuration:self.fastAnimationDuration animations:^{
            // 设置滚动位置
            [self.scrollView setContentOffset:CGPointZero animated:NO];
        } completion:^(BOOL finished) {
            [self executeRefreshingCallback];
        }];
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
    self.mj_x = -self.mj_w;
}

- (void)placeSubviews {
    [super placeSubviews];
    
    self.mj_h = _scrollView.mj_h;
    self.mj_w = MJRefreshLeadWidth;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.alwaysBounceVertical = NO;
    }
}

- (instancetype)linkTo:(UIScrollView *)scrollView {
    scrollView.mj_leader = self;
    return self;
}

/** 刚好看到刷新控件时的contentOffset.x */
- (CGFloat)happenOffsetX {
    return 0;
}

@end
