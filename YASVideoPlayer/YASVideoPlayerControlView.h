//
//  YASVideoPlayerControlView.h
//  KRKit
//
//  Created by chenkaixiao on 2018/12/05
//  Copyright (c) 2015 yasoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YASVideoPlayerControlView : UIView

@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UIView *bottomBar;
/** 切换分辨率按钮 */
@property (nonatomic, strong, readonly) UIButton *resolutionBtn;
/** 分辨率的View */
@property (nonatomic, strong, readonly) UIView   *resolutionView;
/** 分辨率:[{名称:URL}]*/
@property (nonatomic, strong,readonly) NSArray  *resolutionArray;

@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *pauseButton;
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;

@property (nonatomic) UILabel* titleLabel;
@property (copy, nonatomic) void(^resolutionBtnDidClickBlock)(NSString *resolutionName,NSURL *resolutionURL);
- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

- (void)setCloseButtonLeft;

/**
 * 是否有切换分辨率功能
 * @param resolutionArray 分辨率:[{名称:URL}]
 * @param selectIndex 已选分辨率
 */
- (void)setPlayerResolutionDict:(NSArray *)resolutionArray selectResolutionIndex:(NSInteger)selectIndex;
@end
