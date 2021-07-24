//
//  MJRefreshStateLeader.h
//  Mangadex
//
//  Created by John Rion on 2021/7/21.
//

#import "MJRefreshLeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJRefreshStateLeader : MJRefreshLeader

@property (nonatomic, readonly, weak) UILabel *stateLabel;

- (instancetype)setTitle:(NSString *)title forState:(MJRefreshState)state;

@end

NS_ASSUME_NONNULL_END
