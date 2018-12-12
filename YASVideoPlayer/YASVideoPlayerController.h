//
//  KRVideoPlayerController.h
//  KRKit
//
//  Created by chenkaixiao on 2018/12/05
//  Copyright (c) 2015 yasoon. All rights reserved.
//

/**
  * ================================================================================
  * YASVideoPlayer播放器是结合36Kr的KRVideoPlayerController和金山云KSMediaPlayer修改的框架。
  * 优点：
  *    1. 系统方法drawViewHierarchyInRect:afterScreenUpdates截取屏幕时，播放器视图不黑屏
  *    2. 回调videoDataBlock能够实时获取播放时每一帧视频
  *    3. 回调audioDataBlock能够实时获取播放时每一帧音频
  * ================================================================================
 */


#import <KSYMediaPlayer/KSYMoviePlayerController.h>
#import "YASVideoPlayerControlView.h"

@class YASVideoPlayerControlView;
@class YASVideoPlayerController;

@protocol YASVideoPlayerControllerDelegate <NSObject>

@optional
- (void)videoPlayerControllerDidStartPlaying:(YASVideoPlayerController *)moviePlayerController;
- (void)videoPlayerControllerDidPausedPlay:(YASVideoPlayerController *)moviePlayerController;
- (void)videoPlayerControllerDidStopPlay:(YASVideoPlayerController *)moviePlayerController;

- (void)videoPlayerControllerDidShow:(YASVideoPlayerController *)moviePlayerController;
- (void)videoPlayerControllerDidDimissComplete:(YASVideoPlayerController *)moviePlayerController;

- (void)videoPlayerController:(YASVideoPlayerController *)moviePlayerController videoData:(CMSampleBufferRef)pixelBuffer;
- (void)videoPlayerController:(YASVideoPlayerController *)moviePlayerController audioData:(CMSampleBufferRef)sampleBuffer;

- (void)videoPlayerControllerDidFullScreen:(YASVideoPlayerController *)moviePlayerController;
- (void)videoPlayerControllerDidNotFullScreen:(YASVideoPlayerController *)moviePlayerController;

@end

@interface YASVideoPlayerController : KSYMoviePlayerController
@property (nonatomic, strong,readonly) YASVideoPlayerControlView *videoControl;
@property (nonatomic, copy) void (^dimissCompleteBlock)(void);
@property (nonatomic, assign) CGRect frame;
@property (nonatomic) NSString* title;
@property (nonatomic,weak) id<YASVideoPlayerControllerDelegate>delegate;
@property (nonatomic, assign,readonly) BOOL isFullscreenMode;

- (instancetype)initWithFrame:(CGRect)frame ContentURL:(NSURL*)url;


- (void)setVideoURL:(NSURL *)videoURL;

- (void)showInWindow;
- (void)dismiss;

- (void)show:(UIWindow *)window;

- (void)forceFullScreen;

@end
