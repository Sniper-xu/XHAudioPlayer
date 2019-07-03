//
//  ICMusicPlayNarrowView.h
//  DWTeacher
//
//  Created by icochu on 2018/11/22.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMusicPlayModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ViewShowState) {
    ViewRight = 1,          //右侧缩小状态
    ViewShow,               //正常展示状态
    ViewHidden,             //隐藏状态
    ViewBegin,              //初始状态
};
@interface ICMusicPlayNarrowView : UIView

@property(nonatomic, strong) ICMusicPlayModel *currentPlayModel;

@property(nonatomic, assign) ViewShowState showState;

@property(nonatomic, assign) BOOL isRunningAnimate;         //是否在运行动画

@property(nonatomic, copy) void(^leftBtnAction)(BOOL buttenSeleted);

@property(nonatomic, copy) void(^playBtnAction)(BOOL buttenSeleted);

@property(nonatomic, copy) void(^bgImageViewTapAction)(void);

@property(nonatomic, copy) void(^closeBtnAction)(void);

- (instancetype)initWithFrame:(CGRect)frame MusicModel:(ICMusicPlayModel *)model;

//开始一个新动画
- (void)beginImageViewAnimate;

//继续之前动画
- (void)continueImageViewAnimate;

//暂停动画
- (void)stopImageViewAnimate;

//更新新音乐
- (void)updateNewMusicWithModel:(ICMusicPlayModel *)model IsPlaying:(BOOL)isPlay;
@end

NS_ASSUME_NONNULL_END
