YASVideoPlayer
=====


**YASVideoPlayer播放器是结合36Kr的KRVideoPlayerController和金山云KSMediaPlayer修改的框架。**
 
## Features

优点：

- [x] 	统方法drawViewHierarchyInRect:afterScreenUpdates截取屏幕时，播放器视图不黑屏
- [x] 	调videoDataBlock能够实时获取播放时每一帧视频
- [x] 	回调audioDataBlock能够实时获取播放时每一帧音频
- [x] 	支持切换分辨率播放功能
 
 缺点：
 
- [x] 	无法设置audioDataBlock和videoDataBlock回调的频率

## Usage example 
```objc
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = width * (9.0 / 16.0);
        CGFloat y = [UIScreen mainScreen].bounds.size.height - height;
        self.videoController = [[YASVideoPlayerController alloc] initWithFrame:CGRectMake(0, y, width, height) ContentURL:nil];
  
        [self configObserver];
        LKWeakSelf;
        [self.videoController setDimissCompleteBlock:^{
        }];
        [self.videoController show:AppDelegateInstance().window];
        
        
        [self.videoController setVideoURL:url];
        
        
        
        // MARK - CallBack
        - (void)videoPlayerControllerDidStartPlaying:(YASVideoPlayerController *)moviePlayerController;
        - (void)videoPlayerControllerDidPausedPlay:(YASVideoPlayerController *)moviePlayerController;
        - (void)videoPlayerControllerDidStopPlay:(YASVideoPlayerController *)moviePlayerController;

        - (void)videoPlayerControllerDidShow:(YASVideoPlayerController *)moviePlayerController;
        - (void)videoPlayerControllerDidDimissComplete:(YASVideoPlayerController *)moviePlayerController;

        - (void)videoPlayerController:(YASVideoPlayerController *)moviePlayerController videoData:(CMSampleBufferRef)pixelBuffer;
        - (void)videoPlayerController:(YASVideoPlayerController *)moviePlayerController audioData:(CMSampleBufferRef)sampleBuffer;

        - (void)videoPlayerControllerDidFullScreen:(YASVideoPlayerController *)moviePlayerController;
        - (void)videoPlayerControllerDidNotFullScreen:(YASVideoPlayerController *)moviePlayerController;

```

