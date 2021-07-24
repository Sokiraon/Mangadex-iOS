//
//  MJRefreshStateLeader.m
//  Mangadex
//
//  Created by John Rion on 2021/7/21.
//

#import "MJRefreshStateLeader.h"

@interface MJRefreshStateLeader () {
    __unsafe_unretained UILabel *_stateLabel;
}

@property (nonatomic, strong) NSMutableDictionary *stateTitles;

@end

@implementation MJRefreshStateLeader

- (NSMutableDictionary *)stateTitles {
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        UILabel *stateLabel = [UILabel mj_label];
        stateLabel.numberOfLines = 0;
        [self addSubview:_stateLabel = stateLabel];
    }
    return _stateLabel;
}

- (instancetype)setTitle:(NSString *)title forState:(MJRefreshState)state {
    if (title == nil) return self;
    self.stateTitles[@(state)] = title;
    return self;
}

- (void)textConfiguration {
    // 初始化文字
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshLeaderIdleText] forState:MJRefreshStateIdle];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshLeaderPullingText] forState:MJRefreshStatePulling];
    [self setTitle:[NSBundle mj_localizedStringForKey:MJRefreshLeaderPullingText] forState:MJRefreshStateRefreshing];
}

- (void)prepare {
    [super prepare];
    
    [self textConfiguration];
}

- (void)i18nDidChange {
    [self textConfiguration];
    
    [super i18nDidChange];
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];
}

- (void)placeSubviews {
    [super placeSubviews];
    
    if (self.stateLabel.hidden) return;
    
    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    CGFloat stateLabelW = ceil(self.stateLabel.font.pointSize);
    // 状态
    if (noConstrainsOnStatusLabel) {
        self.stateLabel.center = CGPointMake(self.mj_w * 0.5, self.mj_h * 0.5);
        self.stateLabel.mj_size = CGSizeMake(stateLabelW, self.mj_h) ;
    }
}

@end
