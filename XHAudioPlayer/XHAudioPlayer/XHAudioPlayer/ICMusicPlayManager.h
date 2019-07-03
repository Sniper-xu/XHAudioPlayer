//
//  ICMusicPlayManager.h
//  DWTeacher
//
//  Created by icochu on 2018/11/22.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICMusicPlayOpration.h"
#import "ICMusicPlayer.h"
#import "ICMusicPlayFullScreenVC.h"
#import "ICMusicPlayNarrowView.h"
#import "XHComMacro.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<ICMusicPlayModel *> ICMusicModelArray;
typedef struct
{
    //是否需要循环播放，默认不循环
    BOOL isNeedCyclePlay;
    //是否需要展示锁屏播放
    BOOL isShowBackPlayInfo;
    //弹出播放缩小UI距离屏幕底部的距离值，如果y=0,表示不需要UI
    CGFloat playViewY;
    //播放下标
    int playIndex;
    //播放时间以秒为单位
    NSInteger playTimer;
}
ICMusicModePlayerOptions;

@protocol ICMusicPlayManagerDelegate <NSObject>

@optional

-(void)bottomBtnClick:(UIButton *)button Model:(ICMusicPlayModel *)model;
@end

@interface ICMusicPlayManager : NSObject

@property(nonatomic, strong) ICMusicPlayOpration *oprationPlay;

@property(nonatomic, strong) ICMusicPlayer *currentMusicPlayer;

@property(nonatomic, strong) ICMusicPlayModel *currentPlayModel;

@property(nonatomic, assign) id<ICMusicPlayManagerDelegate> delegate;

@property(nonatomic, assign) BOOL isRunning;    //播放器正在运行,用来标记是否移除播放器

@property (nonatomic, readonly) BOOL isPlaying; //播放器在播放还是暂停

@property (nonatomic, readonly) BOOL isClosePlay; //播放器是否关闭

//当前播放缓冲进度
@property (nonatomic, readonly) NSTimeInterval buffingProgress;
//当前播放音乐已播放时间
@property (nonatomic, readonly) NSTimeInterval currentTime;
//当前播放音乐总时间
@property (nonatomic, readonly) NSTimeInterval totalTime;
//当前播放音乐所在的下标
@property (nonatomic, readonly) NSInteger currentPlayIndex;
//是否是最后一首
@property (nonatomic, readonly) BOOL isLastMusic;
//是否是第一首
@property (nonatomic, readonly) BOOL isFirstMusic;
//已准备资源
@property (nonatomic, copy, nullable) void(^playerPrepareToPlay)(id object, ICMusicPlayModel *model);
//已准备播放
@property (nonatomic, copy, nullable) void(^playerReadyToPlay)(id object, ICMusicPlayModel *model);
//播放进度
@property (nonatomic, copy, nullable) void(^playerPlayTimeChanged)(id object, NSTimeInterval currentTime, NSTimeInterval duration);
//缓冲进度
@property (nonatomic, copy, nullable) void(^playerBufferTimeChanged)(id object, NSTimeInterval bufferTime);
//播放状态
@property (nonatomic, copy, nullable) void(^playerPlayStateChanged)(id object, ICAudioPlayerState playState);
//加载状态
@property (nonatomic, copy, nullable) void(^playerLoadStateChanged)(id asset, ICPlayerLoadState loadState);
//播放失败
@property (nonatomic, copy, nullable) void(^playerPlayFailed)(id object, id error);
//一首音乐播放结束
@property (nonatomic, copy, nullable) void(^playerDidToEnd)(id object);
//文章、收藏、分享
@property(nonatomic, copy, nullable) void(^bottomBtnAction)(UIButton *button,ICMusicPlayModel *model);
//关闭播放器
@property (nonatomic, copy, nullable) void(^playerClosed)();

+ (instancetype)sharedManager;
/**
 加载播放的数据
 @param musicArray 需要播放的数据集合
 */
- (void)loadMusicSouceWithMusicArray:(ICMusicModelArray *)musicArray Options:(ICMusicModePlayerOptions)optionsIn;

//开始播放当前音乐
- (void)beginCurrentPlay;

//开始播放当前队列的第一首歌
- (void)beginPlayFirstMusic;

//播放当前队列指定下标
- (void)beginPlayTagMusicWithIndex:(NSInteger)index NarrowViewStatue:(ViewShowState)statue;

//播放下一首
- (void)playNextMusic;

//播放上一首
- (void)playFormerMusic;

//暂停当前音乐的播放
- (void)pausePlay;

//继续播放当前音乐
- (void)continuePlayCurrentMusic;

//结束播放，结束队列播放，清空资源
- (void)stopPlay;

//设置播放进度
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)showNorrowView;

- (void)hiddenNorrowView;
@end

NS_ASSUME_NONNULL_END
