//
//  ICMusicPlayer.m
//  DWTeacher
//
//  Created by icochu on 2018/11/26.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import "ICMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ICMusicKVOManager.h"
#import "XHComMacro.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
static float const kTimeRefreshInterval          = 0.5;
static NSString *const kStatus                   = @"status";
static NSString *const kLoadedTimeRanges         = @"loadedTimeRanges";
static NSString *const kPlaybackBufferEmpty      = @"playbackBufferEmpty";
static NSString *const kPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";

@interface ICMusicPlayer()

@property (nonatomic, strong, readonly) AVURLAsset *asset;

@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;

@property (nonatomic, strong, readonly) AVPlayer *player;

@property (nonatomic, assign) BOOL isBuffering;

@end

@implementation ICMusicPlayer {
    
    CGFloat _playViewY;
    NSArray *_playArray;
    id _timeObserver;
    id _itemEndObserver;
    ICMusicKVOManager *_playerItemKVO;
}

- (instancetype)initWithMusicModel:(ICMusicPlayModel *)model {
    if (self = [super init]) {
        _currentPlayModel = model;
        [self prepareToPlayWithPlayitem:[NSURL URLWithString:_currentPlayModel.audioUrl]];
    }
    return self;
}

- (void)playMusicWithModel:(ICMusicPlayModel *)model PlayStatue:(BOOL)isPlay{
    _currentPlayModel = model;
    [self.player pause];
    if (!isPlay) {
        //player如果已经被移除，重新创建
        [self prepareToPlayWithPlayitem:[NSURL URLWithString:_currentPlayModel.audioUrl]];
    }else {
        //player没有被移除，更改URL、AVPlayerItem开始新的播放
        _isPreparedToPlay = YES;
        _asset = [AVURLAsset assetWithURL:[NSURL URLWithString:model.audioUrl]];
        _playerItem = [AVPlayerItem playerItemWithAsset:_asset];
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
        [self itemObserving];
        if (_playerPrepareToPlay) _playerPrepareToPlay(self, self.currentPlayModel);
    }
}

- (void)prepareToPlayWithPlayitem:(NSURL *)musicURL {
    _isPreparedToPlay = YES;
    [self initializePlayerWithPlayitem:musicURL];
    self.loadState = ICPlayerLoadStatePrepare;
    if (_playerPrepareToPlay) _playerPrepareToPlay(self, self.currentPlayModel);
}

- (void)play {
    if (!_isPreparedToPlay) {
        //判断之前是否初始化过AVPlayer对象，如果还没有完成就先进行初始化
        [self prepareToPlayWithPlayitem:[NSURL URLWithString:_currentPlayModel.audioUrl]];
    } else {
        //完成。可以播放
        [self.player play];
        if (self.rate > 0) self.player.rate = self.rate;
        self.isPlaying = YES;
        self.playState = ICAudioPlayerStatePlaying;
    }
}

- (void)pause {
    //暂停播放
    [self.player pause];
    self.isPlaying = NO;
    self.playState = ICAudioPlayerStatePaused;
}

//结束播放，移除资源
- (void)stop {
    [_playerItemKVO safelyRemoveAllObservers];
    self.playState = ICAudioPlayerStateStopped;
    self.loadState = ICPlayerLoadStateUnknown;
    if (self.player.rate != 0) [self.player pause];
    [self.player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    _itemEndObserver = nil;
    _isPlaying = NO;
    _player = nil;
    _currentPlayModel = nil;
    self.currentTime = 0;
    self.totalTime = 0;
    self.bufferTime = 0;
}

//重播本首音乐
- (void)replay {
    @weakify(self)
    [self seekToTime:0 completionHandler:^(BOOL finished) {
        @strongify(self)
        [self play];
    }];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    CMTime seekTime = CMTimeMake(time, 1);
    [_playerItem cancelPendingSeeks];
    [_player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}

- (void)initializePlayerWithPlayitem:(NSURL *)musicURL {
    _asset = [AVURLAsset assetWithURL:musicURL];
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    //默认不开启静音
    self.muted = NO;
    //设置默认播放速率值
    self.rate = 1;
    if (@available(iOS 9.0, *)) {
        _playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    }
    if (@available(iOS 10.0, *)) {
        //防止新系统有时播放不了情况
        _playerItem.preferredForwardBufferDuration = 1;
        _player.automaticallyWaitsToMinimizeStalling = NO;
    }
    [self itemObserving];
}

- (void)itemObserving {
    [_playerItemKVO safelyRemoveAllObservers];
    _playerItemKVO = [[ICMusicKVOManager alloc] initWithTarget:_playerItem];
    [_playerItemKVO safelyAddObserver:self
                           forKeyPath:kStatus
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    [_playerItemKVO safelyAddObserver:self
                           forKeyPath:kPlaybackBufferEmpty
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    [_playerItemKVO safelyAddObserver:self
                           forKeyPath:kPlaybackLikelyToKeepUp
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    [_playerItemKVO safelyAddObserver:self
                           forKeyPath:kLoadedTimeRanges
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    
    CMTime interval = CMTimeMakeWithSeconds(kTimeRefreshInterval, NSEC_PER_SEC);
    @weakify(self)
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self)
        if (!self) return;
        AVPlayerItem *currentItem = self.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = currentItem.currentTime.value / currentItem.currentTime.timescale;
            NSInteger totalTime = currentItem.duration.value / currentItem.duration.timescale;
            if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(self, currentTime,totalTime);
        }
    }];
    
    _itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self)
        if (!self) return;
        self.playState = ICAudioPlayerStateEnd;
        if (self.playerDidToEnd) self.playerDidToEnd(self);
    }];
}
/// Playback speed switching method
- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem {
    for (AVPlayerItemTrack *track in playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeVideo]) {
            track.enabled = enable;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:kStatus]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                /// 第一次初始化
                self.playState = ICAudioPlayerStateReady;
                if (self.loadState == ICPlayerLoadStatePrepare) {
                    if (self.playerPrepareToPlay) self.playerReadyToPlay(self, self.currentPlayModel);
                }
                
                //处理缓冲情况
                self.loadState = ICPlayerLoadStatePlaythroughOK;
                if (self.seekTime) {
                    [self seekToTime:self.seekTime completionHandler:nil];
                    self.seekTime = 0;
                }
                if (self.isPlaying) [self play];
                self.player.muted = self.muted;
                NSArray *loadedRanges = self.playerItem.seekableTimeRanges;
                if (loadedRanges.count > 0) {
                    if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(self, self.currentTime, self.totalTime);
                }
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.playState = ICAudioPlayerStateError;
                NSError *error = self.player.currentItem.error;
                if (self.playerPlayFailed) self.playerPlayFailed(self, error);
            }
        } else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {
            // When the buffer is empty
            if (self.playerItem.playbackBufferEmpty) {
                self.loadState = ICPlayerLoadStateStalled;
                [self bufferingSomeSecond];
            }
        } else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {
            // When the buffer is good
            if (self.playerItem.playbackLikelyToKeepUp) {
                self.loadState = ICPlayerLoadStatePlayable;
            }
        } else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
            if (self.isPlaying && self.playerItem.playbackLikelyToKeepUp) [self play];
            NSTimeInterval bufferTime = [self availableDuration];
            self.bufferTime = bufferTime;
            if (self.playerBufferTimeChanged) self.playerBufferTimeChanged(self, bufferTime);
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    });
}

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    if (self.isBuffering) return;
    self.isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (!self.isPlaying) {
            self.isBuffering = NO;
            return;
        }
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        self.isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) [self bufferingSomeSecond];
    });
}

/// Calculate buffer progress
- (NSTimeInterval)availableDuration {
    NSArray *timeRangeArray = _playerItem.loadedTimeRanges;
    CMTime currentTime = [_player currentTime];
    BOOL foundRange = NO;
    CMTimeRange aTimeRange = {0};
    if (timeRangeArray.count) {
        aTimeRange = [[timeRangeArray objectAtIndex:0] CMTimeRangeValue];
        if (CMTimeRangeContainsTime(aTimeRange, currentTime)) {
            foundRange = YES;
        }
    }
    
    if (foundRange) {
        CMTime maxTime = CMTimeRangeGetEnd(aTimeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if (playableDuration > 0) {
            return playableDuration;
        }
    }
    return 0;
}

#pragma mark - getter
- (NSTimeInterval)totalTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.player.currentItem.duration);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.playerItem.currentTime);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

#pragma mark - setter
- (void)setPlayState:(ICAudioPlayerState)playState {
    _playState = playState;
    if (self.playerPlayStateChanged) self.playerPlayStateChanged(self, playState);
}

- (void)setLoadState:(ICPlayerLoadState)loadState {
    _loadState = loadState;
    if (self.playerLoadStateChanged) self.playerLoadStateChanged(self, loadState);
}

- (void)setRate:(float)rate {
    _rate  = rate;
    if (self.player && fabsf(_player.rate) > 0.00001f) {
        self.player.rate = rate;
    }
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    self.player.muted = muted;
}


- (void)setVolume:(float)volume {
    _volume = MIN(MAX(0, volume), 1);
    self.player.volume = volume;
}

@end
