//
//  ICMusicPlayManager.m
//  DWTeacher
//
//  Created by icochu on 2018/11/22.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import "ICMusicPlayManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "ICMusicKVOManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import "UIView+XHAdd.h"
#import "XHComMacro.h"
#import "XHToast.h"

#define NarrowViewH     64
#define NarrowViewW     228
@interface ICMusicPlayManager()

@property(nonatomic, strong) ICMusicPlayNarrowView *narrowView;

@property(nonatomic, strong) ICMusicPlayFullScreenVC *fullScreenVC;

@property(nonatomic, strong) ICMusicModelArray *playMusicArray;

@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, assign) NSInteger timerSeconds;            //定时时间

@property(nonatomic, assign) NSInteger timerSelectListIndex;    //选择时间列表下标

@property(nonatomic, assign) BOOL isEndPlay;       //是否刚结束播放

@property(nonatomic, assign) SelectTimeZone timeZone;

@property(nonatomic, assign) NSInteger orderPlayNum;        //正常顺序播放歌曲数

@property (nonatomic, strong) CTCallCenter *callCenter;

@end

@implementation ICMusicPlayManager {
    CGFloat _playViewY;
    NSArray *_playArray;
    int _playIndex;
}

+ (instancetype)sharedManager {
    static ICMusicPlayManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _oprationPlay = [[ICMusicPlayOpration alloc]init];
        self.callCenter = [[CTCallCenter alloc] init];
        @weakify(self);
        [self.callCenter setCallEventHandler:^(CTCall * _Nonnull call) {
            if ([[call callState] isEqual:CTCallStateIncoming]) {
                //电话接通
                @strongify(self);
                if (!self.isPlaying) return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self pausePlay];
                    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
                    [userDefult setObject:@"1" forKey:@"isSystemStopPlay"];
                    [userDefult synchronize];
                });
            }
        }];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
        [self initMusicActionManager];
    }
    return self;
}

-(void)initMusicActionManager{
    if (self.isPlaying) {
        [self pausePlay];
    }
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //耳机拔出，停止播放操作
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pausePlay];
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

- (void)audioInterruption:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict     valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSNumber* seccondReason = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey] ;
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            NSLog(@"收到中断，停止音频播放");
            if (!self.isPlaying) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pausePlay];
                NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
                [userDefult setObject:@"1" forKey:@"isSystemStopPlay"];
                [userDefult synchronize];
            });
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"系统中断结束");
            break;
    }
    switch ([seccondReason integerValue]) {
        case AVAudioSessionInterruptionOptionShouldResume:
            NSLog(@"恢复音频播放");
            break;
        default:
            break;
    }
}

//加载新资源播放信息
- (void)loadMusicSouceWithMusicArray:(ICMusicModelArray *)musicArray Options:(ICMusicModePlayerOptions)optionsIn {
    //废除之前的播放器对象
    if (_currentMusicPlayer != nil) {
        [_currentMusicPlayer stop];
        if(self.playerDidToEnd)self.playerDidToEnd(self.currentMusicPlayer);
        _currentMusicPlayer = nil;
    }
    //设置信息
    if(optionsIn.playTimer > 0){
        [self creatNewTimerWithBeginTime:optionsIn.playTimer];
    }
    _playMusicArray = musicArray;
    if(optionsIn.playViewY > XHScreenHeight) return;
    _playViewY = optionsIn.playViewY;
    _playIndex = optionsIn.playIndex > 0 ? optionsIn.playIndex : 0;
    _currentPlayModel = [_oprationPlay playNewMusicQueueWithModelArray:_playMusicArray PlayIndex:_playIndex];
    if (_currentPlayModel == nil) return;
    //建立新的对象
    _currentMusicPlayer = [[ICMusicPlayer alloc]initWithMusicModel:_currentPlayModel];
    //处理block
    [self playerManagerCallbcak];
    //处理是否显示UI
    if (_playViewY == 0) {
        if (_narrowView != nil) [_narrowView removeFromSuperview];
    }else {
        if(_narrowView == nil) {
            //没有创建一次
            _orderPlayNum = 0;
            _narrowView = [[ICMusicPlayNarrowView alloc]initWithFrame:CGRectMake(XHScreenWidth / 2 - NarrowViewW / 2 ,-NarrowViewH , NarrowViewW, NarrowViewH) MusicModel:_currentPlayModel];
            //初始化状态
            _narrowView.showState = ViewBegin;
            //处理回调
            [self narrowViewCallbcak];
            [[UIApplication sharedApplication].keyWindow addSubview:_narrowView];
        }else {
            //创建过更新UI
            [self updateNarrowInfoWithModel:_currentPlayModel];
        }
    }
}

#pragma mark -publicFunction
//开始播放当前音乐
- (void)beginCurrentPlay {
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    //播放
    [_currentMusicPlayer play];
    //有定时重新计时
    if(self.timerSeconds > 0 && self.timeZone == SelectTimeZoneOne) self.timerSeconds = [self totleTimeClockWithIndex:self.timerSelectListIndex CurrentModel:self.currentPlayModel ModelArray:self.playMusicArray];
    if (!(_narrowView.showState == ViewShow || _narrowView.showState == ViewRight)) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _narrowView.top =  _playViewY;
            _narrowView.showState = ViewShow;
        } completion:nil];
    }else {
        //已有显示更新UI
        [self updateNarrowInfoWithModel:_currentPlayModel];
        [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
    }
    if (!self.isRunning) [self createRemoteCommandCenter];
    self.isRunning = YES;
}

//开始播放当前队列的第一首歌
- (void)beginPlayFirstMusic {
    [self beginPlayTagMusicWithIndex:0 NarrowViewStatue:_narrowView.showState];
}

//播放当前队列指定下标
- (void)beginPlayTagMusicWithIndex:(NSInteger)index NarrowViewStatue:(ViewShowState)statue{
    _currentPlayModel = [_oprationPlay getIndexModelWith:index];
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    //播放
    [_currentMusicPlayer playMusicWithModel:_currentPlayModel PlayStatue:self.isRunning];
    [_currentMusicPlayer play];
    //有定时重新计时
    if(self.timerSeconds > 0 && self.timeZone == SelectTimeZoneOne) self.timerSeconds = [self totleTimeClockWithIndex:self.timerSelectListIndex CurrentModel:self.currentPlayModel ModelArray:self.playMusicArray];
    //展示UI
    if (statue == ViewBegin) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _narrowView.top = _playViewY;
            _narrowView.showState = ViewShow;
        } completion:nil];
    }else {
        //已有显示更新UI
        [self updateNarrowInfoWithModel:_currentPlayModel];
        [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
    }
    if (!self.isRunning) [self createRemoteCommandCenter];
    self.isRunning = YES;
}

//播放下一首
- (void)playNextMusic {
    _currentPlayModel = [_oprationPlay getNextModel];
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    if(self.playerDidToEnd)self.playerDidToEnd(self.currentMusicPlayer);
    //播音乐
    [_currentMusicPlayer playMusicWithModel:_currentPlayModel PlayStatue:self.isRunning];
    [_currentMusicPlayer play];
    //处理UI显示
    [self updateNarrowInfoWithModel:_currentPlayModel];
    //初始播放当前进度调整为0
    self.fullScreenVC.currentProgress = 0;
    //更新数据
    [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
}

//播放上一首
- (void)playFormerMusic {
    _currentPlayModel = [_oprationPlay getFormerModel];
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    if(self.playerDidToEnd)self.playerDidToEnd(self.currentMusicPlayer);
    //播音乐
    [_currentMusicPlayer playMusicWithModel:_currentPlayModel PlayStatue:self.isRunning];
    [_currentMusicPlayer play];
    //处理UI显示
    [self updateNarrowInfoWithModel:_currentPlayModel];
    //初始播放当前进度调整为0
    self.fullScreenVC.currentProgress = 0;
    //更新数据
    [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
}

//暂停当前音乐的播放
- (void)pausePlay {
    if (_currentMusicPlayer.isPlaying) {
        [_currentMusicPlayer pause];
        if (self.narrowView != nil) [self.narrowView stopImageViewAnimate];
        if (self.fullScreenVC != nil)self.fullScreenVC.isPlaying = NO;
        //停止计时
        if (self.timeZone != SelectTimeZoneTwo) [self deallocTimer];
    }
}

//继续播放当前音乐
- (void)continuePlayCurrentMusic {
    if (_currentMusicPlayer.playState == ICAudioPlayerStatePaused || _currentMusicPlayer.playState == ICAudioPlayerStateReady){
        [_currentMusicPlayer play];
        if (self.narrowView != nil) [self.narrowView continueImageViewAnimate];
        if (self.fullScreenVC != nil) self.fullScreenVC.isPlaying = YES;
        //开始计时
        if(self.timerSeconds > 0) [self creatNewTimerWithBeginTime:self.timerSeconds];
    }
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if (time > _currentPlayModel.audioLength) return;
    [self.currentMusicPlayer seekToTime:time completionHandler:completionHandler];
}
//结束播放，结束队列播放，清空资源
- (void)stopPlay {
    if (self.currentMusicPlayer) [_currentMusicPlayer stop];
    [self.oprationPlay removeAllSelectData];
    _currentPlayModel = nil;
    _timerSeconds = 0;
    _timerSelectListIndex = 1;
    _orderPlayNum = 0;
    self.isRunning = NO;
    self.isEndPlay = YES;
    if (self.narrowView != nil) {
        [self.narrowView stopImageViewAnimate];
        [self.narrowView removeFromSuperview];
        self.narrowView = nil;
    }
    if (self.fullScreenVC != nil) {
        [self.fullScreenVC dismissViewControllerAnimated:YES completion:nil];
        self.fullScreenVC = nil;
    }
    [self deallocTimer];
    //去除远程控制
    [self closeRemoteCommandCenter];
    if(self.playerDidToEnd)self.playerDidToEnd(self.currentMusicPlayer);
    if(self.playerClosed)self.playerClosed();
}
- (void)showNorrowView {
    [self.fullScreenVC dismissViewControllerAnimated:YES completion:nil];
}
- (void)hiddenNorrowView {
    if(self.narrowView) {
        self.narrowView.showState = ViewHidden;
        self.narrowView.hidden = YES;
    }
}
#pragma mark - private
//加载计时器
- (void)creatNewTimerWithBeginTime:(NSInteger )beginTime {
    self.timerSeconds = beginTime;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
//注销计时器
- (void)deallocTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
//更新小屏显示信息(开始播放)
- (void)updateNarrowInfoWithModel:(ICMusicPlayModel *)model {
    if (self.narrowView == nil) return;
    [self.narrowView beginImageViewAnimate];
    //开始播放IsPlaying设为yes
    [self.narrowView updateNewMusicWithModel:model IsPlaying:YES];
}
//更新全屏显示控制器信息
- (void)updateFullScreenVCInfoWithModel:(ICMusicPlayModel *)model PlayStatue:(BOOL)isPlaying{
    if (self.fullScreenVC == nil) return;
    self.fullScreenVC.overPlayNum = self.orderPlayNum;
    self.fullScreenVC.musicArray = self.playMusicArray;
    self.fullScreenVC.isPlaying = isPlaying;
    self.fullScreenVC.isLastMusic = self.oprationPlay.isLastData;
    self.fullScreenVC.isFirstMusic = self.oprationPlay.isFirstData;
    self.fullScreenVC.buffingProgress = self.currentMusicPlayer.bufferTime;
    self.fullScreenVC.currentProgress = self.currentMusicPlayer.currentTime;
    self.fullScreenVC.totleTime = self.currentPlayModel.audioLength;
    self.fullScreenVC.currentSelectTimeIndex = self.timerSelectListIndex > 1 ? self.timerSelectListIndex : 1;
    self.fullScreenVC.selectTimeZone = self.timeZone;
    if(self.timerSeconds > 0) self.fullScreenVC.clockTime = self.timerSeconds;
    //最后处理model，
    self.fullScreenVC.currentModel = model;
}

//计算定时
- (NSInteger)totleTimeClockWithIndex:(NSInteger)index CurrentModel:(ICMusicPlayModel *)model ModelArray:(NSArray *)musicArray{
    if (index < 1 || index > 7) return 0;
    NSInteger clockSum = 0;
    if (index > 1 && index < 5) {
        //正常播放完成的去除
        NSInteger newIndex = self.orderPlayNum > 0 ? (index - self.orderPlayNum) : index;
        for (NSInteger i = 0; i < newIndex - 1; i++) {
            if (model.rownum + i > musicArray.count - 1) return clockSum;
            ICMusicPlayModel *playModel = musicArray[model.rownum + i];
            clockSum += playModel.audioLength;
            //只减去当前播放歌曲的进度
            if(self.currentPlayModel.rownum == playModel.rownum) clockSum -= self.currentMusicPlayer.currentTime;
        }
    }else if(index == 1){
        clockSum = 0;
    }else {
        clockSum = 600 * (index - 4);
    }
    return clockSum;
}

//播放结束
- (void)timeOverPlayStop {
    [XHToast showToastVieWiththContent:@"播放已结束"];
    self.timeZone = SelectTimeZoneNone;
    self.timerSeconds = 0;
    self.timerSelectListIndex = 1;
    self.orderPlayNum = 0;
    self.fullScreenVC.selectTimeZone = SelectTimeZoneNone;
    self.fullScreenVC.currentSelectTimeIndex = 1;
    self.fullScreenVC.oldSelectTimeIndex = 1;
    self.fullScreenVC.clockTime = 0;
    self.fullScreenVC.overPlayNum = 0;
    //定时器到时间
    [self pausePlay];
}

#pragma mark - get
- (NSTimeInterval)buffingProgress {
    return self.currentMusicPlayer.bufferTime;
}
- (NSTimeInterval)currentTime {
    return self.currentMusicPlayer.currentTime;
}
- (NSTimeInterval)totalTime {
    return self.currentPlayModel.audioLength;
}
- (NSInteger)currentPlayIndex {
    return self.oprationPlay.currentPlayIndex;
}
- (BOOL)isLastMusic {
    return self.oprationPlay.isLastData;
}
- (BOOL)isFirstMusic {
    return self.oprationPlay.isFirstData;
}
- (BOOL)isPlaying {
    return self.currentMusicPlayer.isPlaying;
}
- (BOOL)isClosePlay {
    return  _currentPlayModel == nil ? YES : NO;
}
#pragma mark - playerBlock
- (void)playerManagerCallbcak {
    @weakify(self)
    self.currentMusicPlayer.playerPrepareToPlay = ^(id object, ICMusicPlayModel *model) {
        @strongify(self)
        if (self.playerPrepareToPlay) self.playerPrepareToPlay(object,model);
    };
    
    self.currentMusicPlayer.playerReadyToPlay = ^(id object, ICMusicPlayModel *model) {
        @strongify(self)
        //准备播放，开启动画
        [self.narrowView beginImageViewAnimate];
        if (self.playerReadyToPlay) self.playerReadyToPlay(object,model);
    };
    
    self.currentMusicPlayer.playerPlayTimeChanged = ^(id object, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self)

        if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(object,currentTime,duration);
        if (self.fullScreenVC != nil) self.fullScreenVC.currentProgress = currentTime;
        
        if ((self.isRunning && !self.isEndPlay) || !self.currentPlayModel) return;
        //重置结束状态
        self.isEndPlay = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            //显示锁屏播放信息
            ICMusicPlayer *player = object;
            ICMusicPlayModel *model = player.currentPlayModel;
            if (model == nil) return;
            NSMutableDictionary * musicDic = [[NSMutableDictionary alloc] init];
            //设置歌曲题目
            [musicDic setObject:model.audioTitle forKey:MPMediaItemPropertyTitle];
            //设置歌手名
            NSString *teacherName = @"轻音乐" ;
            [musicDic setObject:teacherName forKey:MPMediaItemPropertyArtist];
            //设置专辑名
            //        [musicDic setObject:@"专辑名" forKey:MPMediaItemPropertyAlbumTitle];
            //设置歌曲时长
            [musicDic setObject:[NSNumber numberWithDouble:duration]  forKey:MPMediaItemPropertyPlaybackDuration];
            //设置已经播放时长
            [musicDic setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            //设置播放速率
            [musicDic setObject:[NSNumber numberWithInteger:player.rate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
            //设置显示的海报图片
            [musicDic setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithContentsOfFile:model.audioPic]]
                         forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:musicDic];
        });
    };
    
    self.currentMusicPlayer.playerBufferTimeChanged = ^(id object, NSTimeInterval bufferTime) {
        @strongify(self)
        if (self.playerBufferTimeChanged) self.playerBufferTimeChanged(object,bufferTime);
        //处理缓冲进度条UI
        if (self.fullScreenVC != nil) {
            self.fullScreenVC.buffingProgress = bufferTime;
        }
    };
    
    self.currentMusicPlayer.playerPlayStateChanged = ^(id object, ICAudioPlayerState playState) {
        @strongify(self)
        if (self.playerPlayStateChanged) self.playerPlayStateChanged(object, playState);
    };
    
    self.currentMusicPlayer.playerLoadStateChanged = ^(id object, ICPlayerLoadState loadState) {
        @strongify(self)
        if (self.playerLoadStateChanged) self.playerLoadStateChanged(object, loadState);
    };
    
    self.currentMusicPlayer.playerDidToEnd = ^(id object) {
        @strongify(self)
        //播放下一首
        self.isEndPlay = YES;
        if (self.timeZone == SelectTimeZoneOne) self.orderPlayNum += 1;
        if (self.oprationPlay.isLastData) {
            //已经是最后一首
            if (self.timeZone == SelectTimeZoneTwo) {
                [XHToast showToastVieWiththContent:@"播放已结束"];
                [self pausePlay];
            }else {
                [self timeOverPlayStop];
            }
            self.fullScreenVC.currentProgress = 0;
            [self seekToTime:0 completionHandler:nil];
        }else {
            [self playNextMusic];
        }
        if (self.playerDidToEnd) self.playerDidToEnd(object);
    };
    
    self.currentMusicPlayer.playerPlayFailed = ^(id object, id  _Nonnull error) {
        @strongify(self)
        NSLog(@"---------播放出错error:%@--------",error);
        if (self.playerPlayFailed) self.playerPlayFailed(object, error);
    };
}

//锁屏界面开启和监控远程控制事件
- (void)createRemoteCommandCenter{
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    //耳机线控的暂停/播放
    commandCenter.togglePlayPauseCommand.enabled = YES;
    __weak typeof(self) weakSelf = self;
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (weakSelf.isPlaying) {
            [weakSelf.currentMusicPlayer pause];
        }else {
            [weakSelf.currentMusicPlayer play];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [weakSelf.currentMusicPlayer pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [weakSelf.currentMusicPlayer stop];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [weakSelf.currentMusicPlayer play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"上一首");
        if (!weakSelf.isFirstMusic){
            [weakSelf playFormerMusic];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"下一首");
        if (!weakSelf.isLastMusic) {
            [weakSelf playNextMusic];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //在控制台拖动进度条调节进度
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        [weakSelf.currentMusicPlayer seekToTime: playbackPositionEvent.positionTime  completionHandler:^(BOOL finished) {
        
        }];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
}

//关闭远程控制中心
- (void)closeRemoteCommandCenter {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.pauseCommand removeTarget:self];
    [commandCenter.playCommand removeTarget:self];
    [commandCenter.previousTrackCommand removeTarget:self];
    [commandCenter.nextTrackCommand removeTarget:self];
    [commandCenter.changePlaybackPositionCommand removeTarget:self];
    commandCenter = nil;
}

#pragma mark - narrowViewBlock
- (void)narrowViewCallbcak {
    @weakify(self)
    self.narrowView.bgImageViewTapAction = ^{
        //点击背景，展示全图
        @strongify(self)
        self.narrowView.hidden = YES;
        self.narrowView.showState = ViewHidden;
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC.presentedViewController != nil) {
            [rootVC.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
        self.fullScreenVC = [[ICMusicPlayFullScreenVC alloc]init];
        [self updateFullScreenVCInfoWithModel:self.currentPlayModel PlayStatue:self.currentMusicPlayer.isPlaying];
        [self fullScreenVCCallbcak];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.fullScreenVC];
        [rootVC presentViewController:nav animated:YES completion:nil];
    };
    self.narrowView.leftBtnAction = ^(BOOL buttenSeleted) {
        //点击右缩按钮
        @strongify(self)
        if (buttenSeleted) {
            //缩进
            [UIView animateWithDuration:0.3 animations:^{
                self.narrowView.left = XHScreenWidth - 45;
                self.narrowView.showState = ViewRight;
            }];
        }else {
            //展开
            [UIView animateWithDuration:0.3 animations:^{
                self.narrowView.left = XHScreenWidth - NarrowViewW - 15;
                self.narrowView.showState = ViewShow;
            }];
        }
    };
    self.narrowView.playBtnAction = ^(BOOL buttenSeleted) {
        //点击播放按钮
        @strongify(self)
        if (buttenSeleted) {
            //暂停
            [self pausePlay];
        }else {
            //播放
            [self continuePlayCurrentMusic];
        }
    };
    self.narrowView.closeBtnAction = ^{
        //关闭小的播放展示器
        @strongify(self)
        [UIView animateWithDuration:0.3 animations:^{
            self.narrowView.top = XHScreenHeight;
            self.narrowView.showState = ViewHidden;
        }completion:^(BOOL finished) {
            [self stopPlay];
        }];
    };
}

#pragma mark - fullScreenVCCallbcak
- (void)fullScreenVCCallbcak {
    @weakify(self)
    self.fullScreenVC.closeBtnAction = ^(ICMusicPlayModel * _Nonnull currentModel, NSTimeInterval seconds, NSInteger currentSelectTimeListIndex,BOOL isPlaying) {
        @strongify(self)
        //处理显示
        self.currentPlayModel = currentModel;
        self.narrowView.hidden = NO;
        isPlaying ? [self.narrowView beginImageViewAnimate] : [self.narrowView stopImageViewAnimate];
        self.narrowView.showState = ViewShow;
        [self.narrowView updateNewMusicWithModel:currentModel IsPlaying:isPlaying];
        self.fullScreenVC = nil;
        //记录之前选项的时间下标
        _timerSelectListIndex = currentSelectTimeListIndex;
    };

    self.fullScreenVC.formerBtnAction = ^(NSInteger currentSelectTimeListIndex){
        @strongify(self)
        //上一首
        self.timerSelectListIndex = currentSelectTimeListIndex;
        [self playFormerMusic];
    };
    self.fullScreenVC.nextBtnAction = ^(NSInteger currentSelectTimeListIndex) {
        @strongify(self)
        //下一首
        self.timerSelectListIndex = currentSelectTimeListIndex;
        [self playNextMusic];
    };
    self.fullScreenVC.playBtnAction = ^(BOOL buttenSeleted) {
        @strongify(self)
        if (buttenSeleted) {
            //暂停
            [self pausePlay];
        }else {
            //播放
            [self continuePlayCurrentMusic];
        }
    };
    self.fullScreenVC.seekProgress = ^(NSTimeInterval progress) {
        @strongify(self)
        [self seekToTime:progress completionHandler:nil];
    };
    self.fullScreenVC.setTimerPlayOver = ^{
        @strongify(self)
        [self stopPlay];
    };
    self.fullScreenVC.readPlayMusic = ^(NSInteger currentSelectTimeListIndex, ICMusicPlayModel * _Nonnull model) {
        @strongify(self)
        [self beginPlayTagMusicWithIndex:currentSelectTimeListIndex NarrowViewStatue:self.narrowView.showState];
    };
    self.fullScreenVC.currentClockTime = ^(NSTimeInterval seconds,SelectTimeZone selectzon,NSInteger currentSelectTimeListIndex) {
        @strongify(self)
        //选择新的定时，把之前记录已播完的音乐去除
        if(self.timerSelectListIndex != currentSelectTimeListIndex)self.orderPlayNum = 0;
        //记录选择定时下标、区域
        self.timerSelectListIndex = currentSelectTimeListIndex;
        self.timeZone = selectzon;
        if (selectzon == SelectTimeZoneNone) {
            self.timerSeconds = 0;
            [self.fullScreenVC updataTimeShowWithCurrentTime:self.timerSeconds];
            [self deallocTimer];
        }else {
            self.timerSeconds = seconds;
            if (!self.isPlaying && selectzon == SelectTimeZoneOne) {
                //选择第一段而且暂停播放，此时不计时
                [self deallocTimer];
                [self.fullScreenVC updataTimeShowWithCurrentTime:seconds];
            }else {
                //开始计时
                if(self.timerSeconds > 0)[self creatNewTimerWithBeginTime:seconds];
            }
        }
    };
    self.fullScreenVC.bottomBtnAction = ^(UIButton * _Nonnull button,ICMusicPlayModel *model,BOOL showNarrowView) {
        @strongify(self)
        if(button.tag == 100) {
            self.narrowView.hidden = NO;
            if (showNarrowView) return;
            [self.fullScreenVC dismissViewControllerAnimated:YES completion:nil];
            self.fullScreenVC = nil;
        }
        if (self.bottomBtnAction) self.bottomBtnAction(button,model);
        if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBtnClick:Model:)]) {
            [self.delegate bottomBtnClick:button Model:model];
        }
    };
}

- (void)updateTime {
    if (self.timerSeconds == 0) {
        //停止计时器
        [self deallocTimer];
        [self.fullScreenVC updataTimeShowWithCurrentTime:0];
        //已经是最后一首
        [self timeOverPlayStop];
        if (self.oprationPlay.isLastData) {
            self.fullScreenVC.currentProgress = 0;
            [self seekToTime:0 completionHandler:nil];
        }
        return;
    }
    [self.fullScreenVC updataTimeShowWithCurrentTime:self.timerSeconds];
    if(self.timerSeconds > 0) self.timerSeconds -= 1;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
