//
//  YASVideoPlayerControlView.m
//  KRKit
//
//  Created by chenkaixiao on 2018/12/05
//  Copyright (c) 2015 yasoon. All rights reserved.
//

#import "YASVideoPlayerControlView.h"
static const CGFloat kVideoControlBarMargin = 20.0;
static const CGFloat kVideoControlBarWidth = 50.0;
static const CGFloat kVideoControlBarHeight = 40.0;

static const CGFloat kVideoControlResolutionBtnWidth = 64.0;
static const CGFloat kVideoControlResolutionBtnHeight = 26.0;
#define kVideoControlResolutionBtnBgColor [UIColor colorWithRed:0/255.0f green:150/255.0f blue:255/255.0f alpha:1];

static const CGFloat kVideoControlAnimationTimeInterval = 0.3;
static const CGFloat kVideoControlTimeLabelFontSize = 10.0;
static const CGFloat kVideoControlBarAutoFadeOutTimeInterval = 5.0;

@interface YASVideoPlayerControlView ()

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
/** 切换分辨率按钮 */
@property (nonatomic, strong) UIButton *resolutionBtn;
/** 分辨率的View */
@property (nonatomic, strong) UIView   *resolutionView;
/** 分辨率:[{名称:URL}]*/
@property (nonatomic, strong) NSArray  *resolutionArray;;
/** 当前选中的分辨率btn按钮 */
@property (nonatomic, weak  ) UIButton  *resoultionCurrentBtn;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation YASVideoPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topBar];
        [self.topBar addSubview:self.closeButton];
       
        [self addSubview:self.bottomBar];
        [self.bottomBar addSubview:self.playButton];
        [self.bottomBar addSubview:self.pauseButton];
        self.pauseButton.hidden = YES;
        [self.bottomBar addSubview:self.fullScreenButton];
        [self.bottomBar addSubview:self.shrinkScreenButton];
        self.shrinkScreenButton.hidden = YES;
        [self.bottomBar addSubview:self.progressSlider];
        [self.bottomBar addSubview:self.timeLabel];
         [self.bottomBar addSubview:self.resolutionBtn];
        self.resolutionBtn.hidden = YES;
        [self addSubview:self.indicatorView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
        
        [self.topBar addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    self.closeButton.frame = CGRectMake(kVideoControlBarMargin, CGRectGetMinX(self.topBar.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
    
    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kVideoControlBarHeight, CGRectGetWidth(self.bounds), kVideoControlBarHeight);
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    self.pauseButton.frame = self.playButton.frame;
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    
    self.resolutionBtn.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.resolutionBtn.bounds)-CGRectGetWidth(self.fullScreenButton.bounds), 0, CGRectGetWidth(self.resolutionBtn.bounds)+10, CGRectGetHeight(self.bottomBar.bounds));
    
    CGFloat progressSliderWidth = CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetWidth(self.playButton.frame) -CGRectGetWidth(self.resolutionBtn.frame);
    if(self.resolutionBtn.hidden){
        progressSliderWidth +=CGRectGetWidth(self.resolutionBtn.frame);
    }
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.progressSlider.bounds)/2,progressSliderWidth, CGRectGetHeight(self.progressSlider.bounds));
    
    self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bottomBar.bounds) - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds)/2, CGRectGetHeight(self.timeLabel.bounds));
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.titleLabel.frame = self.topBar.bounds;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.isBarShowing = YES;
}

- (void)animateHide
{
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
        self.resolutionView.hidden = YES;
    }];
}

- (void)animateShow
{
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar
{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeInterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

- (void)onTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
        }
    }
}


/**
 是否有切换分辨率功能
 */
- (void)setPlayerResolutionDict:(NSArray *)resolutionArray selectResolutionIndex:(NSInteger)selectIndex{
    self.resolutionBtn.hidden = NO;
    [self layoutSubviews];
    _resolutionArray = resolutionArray;
    NSDictionary *selectDict = resolutionArray[selectIndex];
    NSString *selectResolutionTitle = [selectDict.allKeys firstObject];
    [_resolutionBtn setTitle:selectResolutionTitle  forState:UIControlStateNormal];
    // 添加分辨率按钮和分辨率下拉列表
    self.resolutionView = [[UIView alloc] init];
    self.resolutionView.hidden = YES;
    self.resolutionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self addSubview:self.resolutionView];
    [self bringSubviewToFront:self.resolutionView];
    CGRect bounds=  [[UIScreen mainScreen] bounds];
    CGFloat reViewX = 0;
    CGFloat reViewY = 0;
    CGFloat reViewH = bounds.size.width;
    CGFloat reViewW = bounds.size.height;
    
    self.resolutionView.frame = (CGRect){reViewX,reViewY,reViewW,reViewH};
    
    // 分辨率View上边的Btn
    
    NSInteger btnsCount = resolutionArray.count;
    
    CGFloat reBtnsMargin = 55;
    CGFloat reBtnW = kVideoControlResolutionBtnWidth;
    CGFloat reBtnsLeftMargin = (reViewW - (btnsCount - 1)*reBtnsMargin - reBtnW*btnsCount)*0.5;;
    CGFloat reBtnX = 0;
    CGFloat reBtnY = (reViewH - kVideoControlResolutionBtnHeight)*0.5;
    CGFloat reBtnH = kVideoControlResolutionBtnHeight;
    
    for (NSInteger i = 0 ; i < btnsCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = reBtnH*0.5;
        btn.tag = 200+i;
        reBtnX = reBtnsLeftMargin + i * (reBtnsMargin + reBtnW);
        btn.frame = CGRectMake(reBtnX,reBtnY, reBtnW, reBtnH);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        
        NSDictionary *resolutionDict = _resolutionArray[i];
        NSString *title = [resolutionDict.allKeys firstObject];
        NSString *urlStr = [resolutionDict objectForKey:title];
        
        [btn setTitle:title forState:UIControlStateNormal];
        if ([title isEqualToString:selectResolutionTitle]) {
            self.resoultionCurrentBtn = btn;
            btn.selected = YES;
            btn.backgroundColor =  kVideoControlResolutionBtnBgColor;
        }
        
        if(urlStr==nil){
            btn.enabled = NO;
        }
        
        [self.resolutionView addSubview:btn];
        [btn addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Property

- (UIView *)topBar
{
    if (!_topBar) {
        _topBar = [UIView new];
        _topBar.backgroundColor = [UIColor clearColor];
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [UIView new];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _bottomBar;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-play"]] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _playButton;
}

- (UIButton *)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-pause"]] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _pauseButton;
}

- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-fullscreen"]] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton
{
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-shrinkscreen"]] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _shrinkScreenButton;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-point"]] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-close"]] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, kVideoControlBarHeight, kVideoControlBarHeight);
    }
    return _closeButton;
}

- (UIButton *)resolutionBtn {
    if (!_resolutionBtn) {
        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionBtn.bounds = CGRectMake(0, 0, kVideoControlBarWidth, kVideoControlBarHeight);
        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _resolutionBtn.backgroundColor = [UIColor clearColor];
        _resolutionBtn.titleLabel.textColor = [UIColor whiteColor];
        _resolutionBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _resolutionBtn;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:kVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.bounds = CGRectMake(0, 0, kVideoControlTimeLabelFontSize, kVideoControlTimeLabelFontSize);
    }
    return _timeLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}


#pragma mark - Event
-(void)changeResolution:(UIButton*)sender{
    
    // 隐藏分辨率View
    self.resolutionView.hidden  = YES;
    
    if(sender == self.resoultionCurrentBtn) return;
    
    sender.selected = YES;
    if (sender.isSelected) {
        sender.backgroundColor =  kVideoControlResolutionBtnBgColor;
    } else {
        sender.backgroundColor = [UIColor clearColor];
    }
    self.resoultionCurrentBtn.selected = NO;
    self.resoultionCurrentBtn.backgroundColor = [UIColor clearColor];
    self.resoultionCurrentBtn = sender;
    
    // 分辨率Btn改为normal状态
    self.resolutionBtn.selected = NO;
    // topImageView上的按钮的文字
    [self.resolutionBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    if (self.resolutionBtnDidClickBlock) {
        NSInteger index = sender.tag - 200;
        NSDictionary *data = self.resolutionArray[index];
        self.resolutionBtnDidClickBlock(sender.titleLabel.text,[[data allValues]firstObject]);
    }
}

#pragma mark - Private Method
- (NSString *)videoImageName:(NSString *)name
{
    if (name) {
        NSString *path = [NSString stringWithFormat:@"YASVideoPlayer.bundle/%@",name];
        return path;
    }
    return nil;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _titleLabel;
}

- (void)setCloseButtonLeft {
    self.closeButton.frame = CGRectMake(10, CGRectGetMinX(self.topBar.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));    
}


@end
