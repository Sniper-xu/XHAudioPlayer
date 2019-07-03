//
//  ICMusicPlayFullScreenVC.h
//  DWTeacher
//
//  Created by icochu on 2018/11/28.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMusicPlayModel.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, SlidleStatue) {
    NoMove = 0,          //没有滑动
    MoveForward,         //前滑
    MoveBack,             //后滑
};
typedef NS_ENUM(NSInteger, SelectTimeZone) {
    SelectTimeZoneNone = 0,          //第一段，不开启定时
    SelectTimeZoneOne,               //第二段，开启前xx首
    SelectTimeZoneTwo,               //第三段，xx段时间后，10分钟...
};
NS_ASSUME_NONNULL_BEGIN
@interface ICMusicPlayFullScreenVC : UIViewController

@property(nonatomic, assign) NSTimeInterval currentProgress;    //当前播放进度

@property(nonatomic, assign) NSTimeInterval buffingProgress;    //缓冲进度

@property(nonatomic, assign) NSTimeInterval totleTime;          //总时长

@property(nonatomic, strong) NSArray *musicArray;           //播放列表资源展示

@property(nonatomic, strong) ICMusicPlayModel *currentModel;    //当前播放音乐数据model

@property(nonatomic, assign) BOOL isFirstMusic;         //是否是第一首

@property(nonatomic, assign) BOOL isLastMusic;          //是否是最后一首

@property(nonatomic, assign) BOOL isPlaying;           //是否正在播放

@property(nonatomic, assign) NSInteger clockTime;       //定时时间

@property(nonatomic, assign) NSInteger currentSelectTimeIndex;     //上次选择的定时下标

@property(nonatomic, assign) NSInteger oldSelectTimeIndex;      //当前选择的s定时下标

@property(nonatomic, assign) SelectTimeZone selectTimeZone;     //当前选择的定时时区

@property(nonatomic, assign) NSInteger overPlayNum;         //已经播放的歌曲数

//关闭全屏视图按钮
@property(nonatomic, copy) void(^closeBtnAction)(ICMusicPlayModel *currentModel, NSTimeInterval seconds,NSInteger currentSelectTimeListIndex,BOOL isPlaying);
//上一首按钮点击回调
@property(nonatomic, copy) void(^formerBtnAction)(NSInteger currentSelectTimeListIndex);
//下一首按钮点击回调
@property(nonatomic, copy) void(^nextBtnAction)(NSInteger currentSelectTimeListIndex);
//播放按钮点击回调
@property(nonatomic, copy) void(^playBtnAction)(BOOL buttenSeleted);
//设置定时结束
@property(nonatomic, copy) void(^setTimerPlayOver)(void);
//设置进度
@property(nonatomic, copy) void(^seekProgress)(NSTimeInterval progress);
//列表选择播放
@property(nonatomic, copy) void(^readPlayMusic)(NSInteger currentSelectTimeListIndex,ICMusicPlayModel *model);
//当前剩余的定时时间
@property(nonatomic, copy) void(^currentClockTime)(NSTimeInterval seconds,SelectTimeZone selectzon,NSInteger currentSelectTimeListIndex);
//定时显示
@property(nonatomic, copy) void(^bottomBtnAction)(UIButton *button,ICMusicPlayModel *model,BOOL showNarrowView);
- (void)updataTimeShowWithCurrentTime:(NSInteger)time;

- (NSInteger)totleTimeClockWithIndex:(NSInteger)index CurrentModel:(ICMusicPlayModel *)model ModelArray:(NSArray *)musicArray;
@end

NS_ASSUME_NONNULL_END
