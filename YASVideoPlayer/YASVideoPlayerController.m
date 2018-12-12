//
//  YASVideoPlayerController.m
//  KRKit
//
//  Created by chenkaixiao on 2018/12/05
//  Copyright (c) 2015 yasoon. All rights reserved.
//


#import "YASVideoPlayerController.h"

static const CGFloat kVideoPlayerControllerAnimationTimeInterval = 0.3f;

static  NSString *kCurrentPlaybackTimeKVO = @"currentPlaybackTime";
static  NSString *kClientIPKVO            = @"clientIP";
static  NSString *kLocalDNSIPKVO          = @"localDNSIP";


@interface YASVideoPlayerController (){
    NSTimeInterval lastTime;
}

@property (nonatomic, strong) YASVideoPlayerControlView *videoControl;
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) BOOL isChangingResolutionURL;
@property (nonatomic, assign) CGRect originFrame;

@end

@implementation YASVideoPlayerController

- (void)dealloc {
    [self cancelObserver];
    [self cancelKVObserver];
}

-(instancetype)initWithFrame:(CGRect)frame ContentURL:(NSURL *)url{
    self = [super initWithContentURL:url];
    if(self){
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        self.isChangingResolutionURL = NO;
        [self setupVideoControl];
        [self configObserver];
        [self configKVObserver];
        [self configControlAction];
        
        self.messageDataBlock = ^(NSDictionary *message, int64_t pts, int64_t param) {
            
        };
        __weak typeof (self)weakSelf = self;
        self.videoDataBlock = ^(CMSampleBufferRef pixelBuffer) {
            if([weakSelf.delegate respondsToSelector:@selector(videoPlayerController:videoData:)]){
                [weakSelf.delegate videoPlayerController:weakSelf videoData:pixelBuffer];
            }
        };
        self.audioDataBlock = ^(CMSampleBufferRef sampleBuffer) {
            if([weakSelf.delegate respondsToSelector:@selector(videoPlayerController:audioData:)]){
                [weakSelf.delegate videoPlayerController:weakSelf audioData:sampleBuffer];
            }
        };
        
    }
    return self;
}
#pragma mark - Public Method
- (void)setVideoURL:(NSURL *)videoURL {
//    [self stop];
    [self setUrl:videoURL];
    [self prepareToPlay];
    [self.videoControl.indicatorView startAnimating];
}

- (void)show:(UIWindow *)window {
    if (window) {
        [window addSubview:self.view];
        self.view.alpha = 0.0;
        [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeInterval
            animations:^{
                self.view.alpha = 1.0;
            }
            completion:^(BOOL finished){
                if(self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerControllerDidShow:)]){
                    [self.delegate videoPlayerControllerDidShow:self];
                }
            }];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)showInWindow {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [self show:keyWindow];
}

- (void)dismiss {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self stop];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerControllerDidDimissComplete:)]){
        [self.delegate videoPlayerControllerDidDimissComplete:self];
    }
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeInterval
        animations:^{
            self.view.alpha = 0.0;
        }
        completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            if (self.dimissCompleteBlock) {
                self.dimissCompleteBlock();
            }
        }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method
- (void)configObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMPMediaPlaybackIsPreparedToPlayDidChangeNotification)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMPMovieNaturalSizeAvailableNotification)
                                                 name:MPMovieNaturalSizeAvailableNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMPMoviePlayerSuggestReloadNotification)
                                                 name:MPMoviePlayerSuggestReloadNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMPMoviePlayerNetworkStatusChangeNotification:)
                                                 name:MPMoviePlayerNetworkStatusChangeNotification
                                               object:nil];
    
    /** 另外的通知监听
     * MPMoviePlayerFirstVideoFrameRenderedNotification  第一帧视频
     * MPMoviePlayerFirstAudioFrameRenderedNotification  第一帧音频
     * MPMoviePlayerPlaybackStatusNotification           侦听播放状态出错情况
     * MPMoviePlayerSeekCompleteNotification             侦听Seek拖进度完成状态
     * MPMoviePlayerPlaybackDidFinishNotification        侦听播放结束状态
     */
}

-(void)configKVObserver{
    NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
    [self addObserver:self forKeyPath:kCurrentPlaybackTimeKVO options:opts context:nil];
    [self addObserver:self forKeyPath:kClientIPKVO options:opts context:nil];
    [self addObserver:self forKeyPath:kLocalDNSIPKVO options:opts context:nil];
}

- (void)cancelObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)cancelKVObserver{
    [self removeObserver:self forKeyPath:@"currentPlaybackTime" context:nil];
    [self removeObserver:self forKeyPath:@"clientIP" context:nil];
    [self removeObserver:self forKeyPath:@"localDNSIP" context:nil];
}

- (void)configControlAction {
    [self.videoControl.playButton addTarget:self
                                     action:@selector(playButtonClick)
                           forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self
                                      action:@selector(pauseButtonClick)
                            forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.closeButton addTarget:self
                                      action:@selector(closeButtonClick)
                            forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self
                                           action:@selector(fullScreenButtonClick)
                                 forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self
                                             action:@selector(shrinkScreenButtonClick)
                                   forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self
                                         action:@selector(progressSliderValueChanged:)
                               forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self
                                         action:@selector(progressSliderTouchBegan:)
                               forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self
                                         action:@selector(progressSliderTouchEnded:)
                               forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self
                                         action:@selector(progressSliderTouchEnded:)
                               forControlEvents:UIControlEventTouchUpOutside];
    [self.videoControl.resolutionBtn addTarget:self
                                         action:@selector(resolutionBtnClick:)
                               forControlEvents:UIControlEventTouchUpInside];
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}




#pragma mark - Notification Call Back Method
-(void)onMPMediaPlaybackIsPreparedToPlayDidChangeNotification{
    [self setProgressSliderMaxMinValues];
    [self.videoControl.indicatorView stopAnimating];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification {
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.playButton.hidden = YES;
        [self.videoControl.indicatorView stopAnimating];
        [self.videoControl autoFadeOutControlBar];
        
        if(self.isChangingResolutionURL){
            self.isChangingResolutionURL = NO;
            [self setCurrentPlaybackTime:lastTime];
            [self play];
        }
        if(_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControllerDidStartPlaying:)])
            [_delegate videoPlayerControllerDidStartPlaying:self];
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.playButton.hidden = NO;
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControl animateShow];
            
            if(_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControllerDidStopPlay:)])
                [_delegate videoPlayerControllerDidStopPlay:self];
        }else if (self.playbackState == MPMoviePlaybackStatePaused){
            if(_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControllerDidPausedPlay:)]){
                [_delegate videoPlayerControllerDidPausedPlay:self];
            }
        }
    }
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification {
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControl.indicatorView startAnimating];
    }
    
    if (self.bufferEmptyCount &&
        (MPMovieLoadStatePlayable & self.loadState ||
         MPMovieLoadStatePlaythroughOK & self.loadState)){
            NSLog(@"player finish caching");
            [self.videoControl.indicatorView stopAnimating];
        }
}

/** 画面大小**/
-(void)onMPMovieNaturalSizeAvailableNotification{
//    NSLog(@"video size %.0f-%.0f, rotate:%ld\n", self.naturalSize.width, self.naturalSize.height, (long)self.naturalRotate);
    if(((self.naturalRotate / 90) % 2  == 0 && self.naturalSize.width > self.naturalSize.height) ||
       ((self.naturalRotate / 90) % 2 != 0 && self.naturalSize.width < self.naturalSize.height))
    {
        //如果想要在宽大于高的时候横屏播放，你可以在这里旋转
    }
}
/** 重新加载 **/
-(void)onMPMoviePlayerSuggestReloadNotification{}
/** 网络变化 **/
-(void)onMPMoviePlayerNetworkStatusChangeNotification:(NSNotification*)notify{}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqual:kCurrentPlaybackTimeKVO])
    {
        [self monitorVideoPlayback];
    }
}
#pragma mark - Event
- (void)playButtonClick {
    [self play];
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
}

- (void)pauseButtonClick {
    [self pause];
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
}

- (void)closeButtonClick {
    [self dismiss];
}

- (void)fullScreenButtonClick {
    if (self.isFullscreenMode) {
        return;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    self.isFullscreenMode = YES;
    [UIView animateWithDuration:0.3f
        animations:^{
            self.frame = frame;
            [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        }
        completion:^(BOOL finished) {
            self.videoControl.fullScreenButton.hidden = YES;
            self.videoControl.shrinkScreenButton.hidden = NO;
            if(self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerControllerDidFullScreen:)]){
                [self.delegate videoPlayerControllerDidFullScreen:self];
            }
        }];
}

- (void)shrinkScreenButtonClick {
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f
        animations:^{
            [self.view setTransform:CGAffineTransformIdentity];
            self.frame = self.originFrame;
        }
        completion:^(BOOL finished) {
            self.isFullscreenMode = NO;
            self.videoControl.fullScreenButton.hidden = NO;
            self.videoControl.shrinkScreenButton.hidden = YES;
            if(self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerControllerDidNotFullScreen:)]){
                [self.delegate videoPlayerControllerDidNotFullScreen:self];
            }
        }];
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = floor(duration);
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}
- (void)monitorVideoPlayback {
    double currentTime = floor(self.currentPlaybackTime);
    lastTime = self.currentPlaybackTime;
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
}

- (void)resolutionBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    // 显示隐藏分辨率View
    self.videoControl.resolutionView.hidden = !sender.isSelected;
}

#pragma mark - set up UI param
-(void)setupVideoControl{
    
    [self.view addSubview:self.videoControl];
    self.videoControl.frame = self.view.bounds;
    
    __weak typeof(self)weakSelf = self;
    _videoControl.resolutionBtnDidClickBlock = ^(NSString *resolutionName, NSURL *resolutionURL) {
        weakSelf.isChangingResolutionURL = YES;
        [weakSelf reload:resolutionURL flush:NO];
    };
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    /*
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];

    double minutesRemaining = floor(totalTime / 60.0);
    ;
    double secondsRemaining = floor(fmod(totalTime, 60.0));
    ;
    
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    */
    
    NSString *timeElapsedString = [self timeFormat:currentTime];
    NSString *timeRmainingString = [self timeFormat:totalTime];

    self.videoControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@", timeElapsedString, timeRmainingString];
}

- (void)fadeDismissControl {
    [self.videoControl animateHide];
}

#pragma mark - Property
- (YASVideoPlayerControlView *)videoControl {
    if (!_videoControl) {
        _videoControl = [[YASVideoPlayerControlView alloc] init];
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView {
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame {
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}

#pragma mark - Self
- (void)forceFullScreen {
    if (self.isFullscreenMode) {
        return;
    }
    
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    self.isFullscreenMode = YES;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.frame = frame;
                         [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                     }
                     completion:^(BOOL finished) {
                         
                         self.videoControl.fullScreenButton.hidden = YES;
                         self.videoControl.shrinkScreenButton.hidden = YES;
                         if(self.delegate&&[self.delegate respondsToSelector:@selector(videoPlayerControllerDidFullScreen:)]){
                             [self.delegate videoPlayerControllerDidFullScreen:self];
                         }
                     }];
    
    [self.videoControl setCloseButtonLeft];
}

-(void)setTitle:(NSString *)title{
    self.videoControl.titleLabel.text = title;
    
    if (title.length != 0) {
        self.videoControl.topBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    } else {
        self.videoControl.topBar.backgroundColor = [UIColor clearColor];
    }
}

- (NSString *)timeFormat:(double)time {
    int duration = time;
    
    int hours = (int)(duration / 3600);
    int minutes = (int)(duration / 60 % 60);
    int seconds = (int)(duration % 60);
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}


@end
