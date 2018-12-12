# YASVideoPlayer

 YASVideoPlayer播放器是结合36Kr的KRVideoPlayerController和金山云KSMediaPlayer修改的框架。
 
 优点：
 * 统方法drawViewHierarchyInRect:afterScreenUpdates截取屏幕时，播放器视图不黑屏
 * 调videoDataBlock能够实时获取播放时每一帧视频
 * 回调audioDataBlock能够实时获取播放时每一帧音频
 
 缺点：
 * 无法设置audioDataBlock和videoDataBlock回调的频率

