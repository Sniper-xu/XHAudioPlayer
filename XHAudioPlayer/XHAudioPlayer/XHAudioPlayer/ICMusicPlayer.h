//
//  ICMusicPlayer.h
//  DWTeacher
//
//  Created by icochu on 2018/11/26.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICMusicPlayModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ICAudioPlayerState) {
    ICAudioPlayerStateReady,                //已经准备好播放
    ICAudioPlayerStatePlaying = (1 << 1),    //开始播放播放
    ICAudioPlayerStateBuffering = (1 << 2), //正在缓冲
    ICAudioPlayerStateEnd = (1 << 3),        //一首歌播放结束
    ICAudioPlayerStatePaused = (1 << 4),    //暂停
    ICAudioPlayerStateStopped = (1 << 5),    //停止播放，播放器不再运行
    ICAudioPlayerStateError = (1 << 6),       //播放出错
};

typedef NS_OPTIONS(NSUInteger, ICPlayerLoadState) {
    ICPlayerLoadStateUnknown        = 0,
    ICPlayerLoadStatePrepare        = 1 << 0,
    ICPlayerLoadStatePlayable       = 1 << 1,
    ICPlayerLoadStatePlaythroughOK  = 1 << 2,
    ICPlayerLoadStateStalled        = 1 << 3,
};

@interface ICMusicPlayer : NSObject

//音量
@property(nonatomic,assign) float volume;
//是否静音
@property(nonatomic, getter=isMuted) BOOL muted;
//播放速度,0.5...2
@property (nonatomic, assign) float rate;
//当前播放时间
@property (nonatomic, assign) NSTimeInterval currentTime;
//本首音乐总时间
@property (nonatomic, assign) NSTimeInterval totalTime;
//已缓冲时间
@property (nonatomic, assign) NSTimeInterval bufferTime;
//选择播放时间
@property (nonatomic) NSTimeInterval seekTime;
//是否在播放
@property (nonatomic, assign) BOOL isPlaying;
//是否已经准备好播放
@property (nonatomic, assign) BOOL isPreparedToPlay;
//当前播放音乐的数据model
@property(nonatomic, strong) ICMusicPlayModel *currentPlayModel;
//播放状态
@property (nonatomic, readonly) ICAudioPlayerState playState;
//加载状态
@property (nonatomic, readonly) ICPlayerLoadState loadState;
//已准备好，可以开始加载资源
@property (nonatomic, copy, nullable) void(^playerPrepareToPlay)(id object, ICMusicPlayModel *model);
//已加载资源完备，可以准备播放
@property (nonatomic, copy, nullable) void(^playerReadyToPlay)(id object, ICMusicPlayModel *model);
//已播放时长回调
@property (nonatomic, copy, nullable) void(^playerPlayTimeChanged)(id object, NSTimeInterval currentTime, NSTimeInterval duration);
//已缓冲时长回调
@property (nonatomic, copy, nullable) void(^playerBufferTimeChanged)(id object, NSTimeInterval bufferTime);
//播放状态变化回调
@property (nonatomic, copy, nullable) void(^playerPlayStateChanged)(id object, ICAudioPlayerState playState);
//加载状态变化回调
@property (nonatomic, copy, nullable) void(^playerLoadStateChanged)(id object, ICPlayerLoadState loadState);
//播放失败回调
@property (nonatomic, copy, nullable) void(^playerPlayFailed)(id object, id error);
//播放结束回调
@property (nonatomic, copy, nullable) void(^playerDidToEnd)(id object);

//初始化
- (instancetype)initWithMusicModel:(ICMusicPlayModel *)model;

//播放
- (void)play;
//暂停
- (void)pause;
//重播
- (void)replay;
//退出
- (void)stop;
//选择时间播放
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
//播放model指定音乐
- (void)playMusicWithModel:(ICMusicPlayModel *)model PlayStatue:(BOOL)isPlay;
@end

NS_ASSUME_NONNULL_END
