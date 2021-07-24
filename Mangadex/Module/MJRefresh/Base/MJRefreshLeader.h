//
//  MJRefreshLeader.h
//  Mangadex
//
//  Created by John Rion on 2021/7/21.
//

#import "MJRefreshComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJRefreshLeader : MJRefreshComponent

/** 创建leader*/
+ (instancetype)leaderWithRefreshingBlock:(MJRefreshComponentAction)refreshingBlock;
/** 创建leader */
+ (instancetype)leaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

/** 忽略多少scrollView的contentInset的right */
@property (assign, nonatomic) CGFloat ignoredScrollViewContentInsetRight;


@end

NS_ASSUME_NONNULL_END
