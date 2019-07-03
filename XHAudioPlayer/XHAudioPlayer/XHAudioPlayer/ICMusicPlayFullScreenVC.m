//
//  ICMusicPlayFullScreenVC.m
//  DWTeacher
//
//  Created by icochu on 2018/11/28.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import "ICMusicPlayFullScreenVC.h"
#import "UIImage+ImageEffects.h"
#import "ICMusicPlayListVC.h"
#import "XHComMacro.h"
#import "UIButton+Style.h"
#import "UIView+XHAdd.h"
#import "Common.h"

@interface ICMusicPlayFullScreenVC ()<UINavigationControllerDelegate>

@property(nonatomic, strong) UIView *bottomOprateView;              //底部视图

@property(nonatomic, strong) UIView *middlePlayView;                //中间视图展示
@property(nonatomic, strong) UIProgressView *progressView;          //缓冲进度条
@property(nonatomic, strong) UISlider *sliderView;                  //播放进度条
@property(nonatomic, strong) UIButton *playListBtn;                 //播放列表
@property(nonatomic, strong) UILabel *beginTime;                    //起始时间
@property(nonatomic, strong) UILabel *endTime;                      //结束时间
@property(nonatomic, strong) UIButton *timeBtn;                     //时间倒计时
@property(nonatomic, strong) UIButton *formerBtn;                   //上一首
@property(nonatomic, strong) UIButton *playBtn;                     //播放、暂停
@property(nonatomic, strong) UIButton *nextBtn;                     //下一首

@property(nonatomic, strong) UIImageView *topBGImageView;           //背景虚图
@property(nonatomic, strong) UIButton *leftBtn;                     //左上角向下按钮

@property(nonatomic, strong) UIImageView *columnBackImageView;      //专栏图片
@property(nonatomic, strong) UILabel *columnTitle;                  //专栏名字
@property(nonatomic, strong) UILabel *articleTitle;                 //文章名字

@property(nonatomic, strong) UIView *timeSelectView;                //时间选择视图
@property(nonatomic, strong) UIView *timeListMaskView;
@property(nonatomic, strong)NSTimer *progressTimer;                  //处理进度

@property (nonatomic,strong)CABasicAnimation *basicAnimation;

@end

@implementation ICMusicPlayFullScreenVC {
    NSArray *_btnNameArray;         //底部功能按钮集合
    NSArray *_btnselectArray;       //底部功能选中状态按钮集合
    NSArray *_titleNameArray;       //底部功能按钮标题
    NSMutableArray *_bottomBtns;
    NSArray *_timeListNameArray;            //时间选择视图选择项
    NSMutableArray *_timeButtonArray;
    NSMutableArray *_timeImageViewArray;
    SlidleStatue slideStatue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _bottomBtns = @[].mutableCopy;
    _timeButtonArray = @[].mutableCopy;
    _timeImageViewArray = @[].mutableCopy;
    _btnNameArray = @[@"fullView_ article",@"helpAnswer_com_fablous",@"fullView_ share"];
    _btnselectArray = @[@"fullView_ article",@"helpAnswer_answerDetail_agree_s",@"fullView_ share"];
    _titleNameArray = @[@"文章",@"0",@"分享"];
    _timeListNameArray = @[@"定时关闭",@"不开启",@"播完当前音频后",@"播完2段音频后",@"播完3段音频后",@"10分钟后",@"20分钟后",@"30分钟后",@"取消"];
    
    [self setNavigationBarHidden];
    [self initView];
    [self initTimeView];

}
- (void)setNavigationBarHidden {
    self.navigationController.navigationBarHidden = YES;
}

- (void)initView {
    //底部三个按钮
    _bottomOprateView = [[UIView alloc]initWithFrame:CGRectMake(0, XHScreenHeight - 55 - SafeAreaBottomHeight, XHScreenWidth, 55 + SafeAreaBottomHeight)];
    _bottomOprateView.backgroundColor = XHUIColorFromRGB(0xfafafa);
    [self.view addSubview:_bottomOprateView];
    
    for (NSInteger i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake(XHScreenWidth / 3 * i , 0, XHScreenWidth / 3, 55);
        button.tag = 100 + i;
        [button setTitleColor:XHAPPSubheadColor forState:UIControlStateNormal];
        [button setTitleColor:XHAPPMainColor forState:UIControlStateSelected];
        button.titleLabel.font = FONT(12);
        [button setImage:[UIImage imageNamed:_btnNameArray[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:_btnselectArray[i]] forState:UIControlStateSelected];
        if (i == 1) {
            NSString *titleS = @"点赞";
            [button setTitle:titleS forState:UIControlStateNormal];
            button.selected = NO ;
        }else {
            [button setTitle:_titleNameArray[i] forState:UIControlStateNormal];
        }
        [button layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:7];
        [button addTarget:self action:@selector(bottomBtnsAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomOprateView addSubview:button];
        [_bottomBtns addObject:button];
    }
    
    _middlePlayView = [[UIView alloc]initWithFrame:CGRectMake(0, XHScreenHeight - 55 - SafeAreaBottomHeight - 160, XHScreenHeight, 160)];
    _middlePlayView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_middlePlayView];
    
    _playListBtn = [UIButton new];
    _playListBtn.size = CGSizeMake(54, 54);
    _playListBtn.left = 8;
    _playListBtn.top = 80;
    [_playListBtn setTitle:@"播放列表" forState:UIControlStateNormal];
    [_playListBtn setImage:IMAGE(@"fullView_playList") forState:UIControlStateNormal];
    _playListBtn.titleLabel.font = FONT(12);
    [_playListBtn setTitleColor:XHAPPTipsColor forState:UIControlStateNormal];
    [_playListBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:2];
    [_playListBtn addTarget:self action:@selector(_playListBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_middlePlayView addSubview:_playListBtn];
    
    _timeBtn = [UIButton new];
    _timeBtn.size = CGSizeMake(55, 55);
    _timeBtn.right = XHScreenWidth - 3;
    _timeBtn.top = 80;
    NSString *timeS = _clockTime > 0 ? [Common updataTimerLableWithSecond:_clockTime] : @"定时关闭";
    [_timeBtn setTitle:timeS forState:UIControlStateNormal];
    _timeBtn.titleLabel.font = FONT(12);
    _timeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_timeBtn setTitleColor:XHAPPTipsColor forState:UIControlStateNormal];
    [_timeBtn setImage:IMAGE(@"fullView_time") forState:UIControlStateNormal];
    [_timeBtn addTarget:self action:@selector(timeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_timeBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:2];
    [_middlePlayView addSubview:_timeBtn];
    
    _playBtn = [UIButton new];
    _playBtn.size = CGSizeMake(78, 78);
    _playBtn.top = 61;
    _playBtn.left = XHScreenWidth / 2 - 39;
    [_playBtn setImage:IMAGE(@"fullView_ playBtn_puse") forState:UIControlStateSelected];
    [_playBtn setImage:IMAGE(@"fullView_ playBtn_play") forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(_playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _playBtn.selected = !_isPlaying;
    [_middlePlayView addSubview:_playBtn];
    
    _formerBtn = [UIButton new];
    _formerBtn.size = CGSizeMake(46, 46);
    _formerBtn.left = (XHScreenWidth / 2 - 39 - 48 ) / 2 - 23 + 48;
    _formerBtn.centerY = _playBtn.centerY;
    [_formerBtn setImage:IMAGE(@"fullView_playBtn_left_n") forState:UIControlStateNormal];
    [_formerBtn setImage:IMAGE(@"fullView_playBtn_left_f") forState:UIControlStateDisabled];
    [_formerBtn addTarget:self action:@selector(_formerBtnAction) forControlEvents:UIControlEventTouchUpInside];
    if (_isFirstMusic) _formerBtn.enabled = NO;
    [_middlePlayView addSubview:_formerBtn];
    
    _nextBtn = [UIButton new];
    _nextBtn.size = CGSizeMake(46, 46);
    _nextBtn.left = XHScreenWidth / 2 + 39 + (XHScreenWidth / 2 - 39 - 48 ) / 2 - 23;
    _nextBtn.centerY = _playBtn.centerY;
    [_nextBtn setImage:IMAGE(@"fullView_playBtn_right_n") forState:UIControlStateNormal];
    [_nextBtn setImage:IMAGE(@"fullView_playBtn_right_f") forState:UIControlStateDisabled];
    [_nextBtn addTarget:self action:@selector(_nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    if (_isLastMusic) _nextBtn.enabled = NO;
    [_middlePlayView addSubview:_nextBtn];
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(12,21, XHScreenWidth - 24, 3)];
    _progressView.layer.masksToBounds = YES;
    _progressView.layer.cornerRadius = 1.5;
    _progressView.trackTintColor= XHUIColorFromRGB(0xd4d4d4);          //设置进度条颜色
    _progressView.progressTintColor= XHUIColorFromRGB(0xe8e8e8);      //缓冲进度条上进度的颜色
    _progressView.progress = _buffingProgress / self.currentModel.audioLength;
    [_middlePlayView addSubview:_progressView];
    
    _sliderView = [[UISlider alloc]initWithFrame:CGRectMake(12,12, XHScreenWidth - 24, 20)];
    _sliderView.layer.masksToBounds = YES;
    _sliderView.layer.cornerRadius = 1.5;
    _sliderView.minimumValue = 0;
    _sliderView.maximumValue = self.currentModel.audioLength;
    _sliderView.value = self.currentProgress;
    _sliderView.continuous = YES;
    _sliderView.minimumTrackTintColor = XHAPPMainColor;
    _sliderView.maximumTrackTintColor = [UIColor clearColor];
    [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    [_sliderView addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    [_sliderView setThumbImage:IMAGE(@"fullView_progress") forState:UIControlStateNormal];
    [_middlePlayView addSubview:_sliderView];
    
    _beginTime = [UILabel new];
    _beginTime.left = _progressView.left;
    _beginTime.top = _progressView.bottom + 8;
    _beginTime.size = CGSizeMake(80, 14);
    _beginTime.text = @"00:00";
    _beginTime.font = FONT(10);
    _beginTime.textColor = XHAPPTipsColor;
    [_middlePlayView addSubview:_beginTime];
    [Common updataTimerLableWithLable:_beginTime Second:_currentProgress];
    
    _endTime = [UILabel new];
    _endTime.left = _progressView.right - 80;
    _endTime.top = _progressView.bottom + 8;
    _endTime.size = CGSizeMake(80, 14);
    _endTime.textAlignment = NSTextAlignmentRight;
    _endTime.text = @"00:00";
    _endTime.font = FONT(10);
    _endTime.textColor = XHAPPTipsColor;
    [_middlePlayView addSubview:_endTime];
    [Common updataTimerLableWithLable:_endTime Second:_currentModel.audioLength];
    
    _topBGImageView = [UIImageView new];
    _topBGImageView.userInteractionEnabled = YES;
    _topBGImageView.frame = CGRectMake(0, 0, XHScreenWidth, XHScreenHeight - 160 - 55 - SafeAreaBottomHeight);
    UIImage *columnImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"4" ofType:@"jpg"]];
    self.topBGImageView.image = [columnImage blurImage];
    [self.view addSubview:_topBGImageView];
    
    _leftBtn = [UIButton new];
    _leftBtn.size = CGSizeMake(22, 22);
    _leftBtn.left = 17;
    _leftBtn.top = 32 + SafeAreaTopAddHeight;
    [_leftBtn setImage:IMAGE(@"fullView_down_arrow") forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(_leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_topBGImageView addSubview:_leftBtn];
    
    _columnBackImageView = [UIImageView new];
    _columnBackImageView.layer.masksToBounds = YES;
    CGFloat columnBackImageH = _topBGImageView.height - 210 - SafeAreaTopAddHeight;
    CGFloat columnBackImageW = columnBackImageH * 3 / 4;
    _columnBackImageView.frame = CGRectMake(XHScreenWidth / 2 - columnBackImageW / 2, 120 + SafeAreaTopAddHeight , columnBackImageW, columnBackImageW);
    _columnBackImageView.image = [UIImage imageWithContentsOfFile:_currentModel.audioPic];
    _columnBackImageView.layer.cornerRadius = columnBackImageW / 2;
    [_topBGImageView addSubview:_columnBackImageView];
    
    _columnTitle = [UILabel new];
    _columnTitle.font = [UIFont boldSystemFontOfSize:18];
    _columnTitle.left = 15;
    _columnTitle.top = _columnBackImageView.bottom + 50;
    _columnTitle.size = CGSizeMake(XHScreenWidth - 30, 24);
    _columnTitle.textColor = [UIColor whiteColor];
    _columnTitle.textAlignment = NSTextAlignmentCenter;
    _columnTitle.numberOfLines = 0;
    _columnTitle.text = _currentModel.columnName;
    [_topBGImageView addSubview:_columnTitle];
    
    _articleTitle = [UILabel new];
    _articleTitle.font = FONT(15);
    _articleTitle.left = 15;
    _articleTitle.top = _columnTitle.bottom + 15;
    _articleTitle.size = CGSizeMake(XHScreenWidth - 30, 19);
    _articleTitle.textColor = [UIColor whiteColor];
    _articleTitle.textAlignment = NSTextAlignmentCenter;
    _articleTitle.numberOfLines = 0;
    _articleTitle.text = _currentModel.audioTitle;
    [_topBGImageView addSubview:_articleTitle];
}

- (void)initTimeView {
    _oldSelectTimeIndex = _currentSelectTimeIndex;
    _timeListMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, XHScreenWidth, XHScreenHeight)];
    _timeListMaskView.alpha = 0.5;
    _timeListMaskView.backgroundColor = XHUIColorFromRGB(0x000000);
    _timeListMaskView.hidden = YES;
    UITapGestureRecognizer *timeListMaskViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timeListMaskViewTapAction)];
    [_timeListMaskView addGestureRecognizer:timeListMaskViewTap];
    [self.view addSubview:_timeListMaskView];
    
    _timeSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, XHScreenHeight, XHScreenWidth, 445 + SafeAreaBottomHeight)];
    _timeSelectView.backgroundColor = XHAPPSeparateColor;
    for (NSInteger i = 0; i < _timeListNameArray.count; i++) {
        UIButton *btn = [UIButton new];
        [btn setTitle:_timeListNameArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:XHAPPTitleColor forState:UIControlStateNormal];
        [btn setTitleColor:XHAPPMainColor forState:UIControlStateSelected];
        btn.tag = 100 + i;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = XHAPPBGColor.CGColor;
        btn.layer.masksToBounds = YES;
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(timeBtnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        [_timeSelectView addSubview:btn];
        [_timeButtonArray addObject:btn];
        
        UIImageView *imageView = [UIImageView new];
        imageView.image = IMAGE(@"icon_check_h");
        imageView.hidden = (i == _currentSelectTimeIndex) ? NO : YES;
        [btn addSubview:imageView];
        [_timeImageViewArray addObject:imageView];
        
        if (i == 0) {
            btn.frame = CGRectMake(0, 0, XHScreenWidth, 44);
            [btn setTitleColor:XHAPPSubheadColor forState:UIControlStateNormal];
            btn.titleLabel.font = FONT(14);
            imageView.frame = CGRectMake(XHScreenWidth - 15 - 22, 11 , 22, 22);
        }else {
            if (i == _timeListNameArray.count - 1) {
                btn.frame = CGRectMake(0, 445 - 50 , XHScreenWidth, 50 + SafeAreaBottomHeight);
                btn.selected = YES;
            }else {
                btn.frame = CGRectMake(0, 44 + (i - 1) * 49, XHScreenWidth, 49);
                imageView.frame = CGRectMake(XHScreenWidth - 15 - 22, 13.5 , 22, 22);
                btn.selected = (i == _currentSelectTimeIndex) ? YES : NO;
            }
        }
    }
    [self.view addSubview:_timeSelectView];
}

#pragma mark - set
- (void)setCurrentModel:(ICMusicPlayModel *)currentModel {
    if (currentModel == nil) return;
    _currentModel  = currentModel;
    //中间图
    _columnBackImageView.image = [UIImage imageWithContentsOfFile:_currentModel.audioPic];
    _columnTitle.text = currentModel.columnName;
    _articleTitle.text = currentModel.audioTitle;
    
    //进度条
    self.totleTime = self.currentModel.audioLength;
    self.sliderView.maximumValue = self.currentModel.audioLength;//音乐总共时长
    [Common updataTimerLableWithLable:_endTime Second:currentModel.audioLength];
    
    //上一首，下一首，更新定时显示
    if(self.selectTimeZone != SelectTimeZoneTwo)[self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:currentModel];
}

- (void)setCurrentProgress:(NSTimeInterval)currentProgress {
    _currentProgress = currentProgress;
    _sliderView.value  = currentProgress;
    [Common updataTimerLableWithLable:_beginTime Second:currentProgress];
}
- (void)setBuffingProgress:(NSTimeInterval)buffingProgress {
    _buffingProgress = buffingProgress;
    _progressView.progress = buffingProgress / self.currentModel.audioLength;
}

- (void)setTotleTime:(NSTimeInterval)totleTime {
    _totleTime = totleTime;
    [Common updataTimerLableWithLable:_endTime Second:totleTime];
}
- (void)setIsLastMusic:(BOOL)isLastMusic {
    _isLastMusic = isLastMusic;
    _nextBtn.enabled = !isLastMusic;
}
- (void)setIsFirstMusic:(BOOL)isFirstMusic {
    _isFirstMusic = isFirstMusic;
    _formerBtn.enabled = !isFirstMusic;
}
- (void)setIsPlaying:(BOOL )isPlaying {
    _isPlaying = isPlaying;
    _playBtn.selected = !isPlaying;
}
- (void)setClockTime:(NSInteger)clockTime {
    _clockTime = clockTime;
    //当选择10分钟以上定时，由外部管理定时不需要重新计算
    if (self.currentSelectTimeIndex > 4) return;
    NSString *timeS = _clockTime > 0 ? [Common updataTimerLableWithSecond:_clockTime] : @"定时关闭";
    [_timeBtn setTitle:timeS forState:UIControlStateNormal];
    [_timeBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:2];
}

#pragma mark - prive
- (void)_leftBtnAction {
   
    if (self.progressTimer != nil) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    //传出数据
    if (self.closeBtnAction) self.closeBtnAction(_currentModel,_clockTime, _currentSelectTimeIndex,_isPlaying);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 底部三个按钮
- (void)bottomBtnsAction:(UIButton *)button {
    
    switch (button.tag) {
        case 100:
            break;
        case 101:
            [self clickFabulousBtnAction:button];
            break;
        case 102:
            [self shareBtnAction];
            break;
        default:
            break;
    }
}
//点赞
- (void)clickFabulousBtnAction:(UIButton *)button{
    
}
- (void)shareBtnAction {
    
    //进入更多
}

#pragma mark - 中间播放控制视图按钮
- (void)_playListBtnAction {
    //弹出列表
    ICMusicPlayListVC *plistVC = [ICMusicPlayListVC new];
    plistVC.allListModelArray = self.musicArray;
    plistVC.currentModel = self.currentModel;
    plistVC.isPlaying = self.isPlaying;
    @weakify(self)
    plistVC.readPlayMusic = ^(NSInteger currentSelectTimeListIndex, ICMusicPlayModel *model) {
        @strongify(self)
        if(self.readPlayMusic)self.readPlayMusic(currentSelectTimeListIndex, model);
    };
    [self.navigationController pushViewController:plistVC animated:YES];
}
- (void)timeBtnAction {
    //弹出时间列表
    _timeListMaskView.hidden = NO;
    for (NSInteger i = 0; i < _timeImageViewArray.count; i++) {
        UIImageView *imageView = _timeImageViewArray[i];
        imageView.hidden = (i == _currentSelectTimeIndex) ? NO : YES;
        UIButton *button = _timeButtonArray[i];
        if (i == 0) {
            button.selected = NO;
        }else {
            if (i == _timeListNameArray.count - 1) {
                button.selected = YES;
            }else {
                button.selected = (i == _currentSelectTimeIndex) ? YES : NO;
            }
        }
    }
    _oldSelectTimeIndex = _currentSelectTimeIndex;
    [UIView animateWithDuration:0.3 animations:^{
        self->_timeSelectView.top = XHScreenHeight - 445 - SafeAreaBottomHeight;
    }];
}
- (void)_playBtnAction:(UIButton *)button {
    //播放、暂停
    button.selected = !button.selected;
    _isPlaying = !button.selected;
    if (self.playBtnAction) self.playBtnAction(button.selected);
}

- (void)_formerBtnAction {
    //上一曲,先处理定时
    self.currentProgress = 0;
    if(self.formerBtnAction) self.formerBtnAction(self.currentSelectTimeIndex);
}

- (void)_nextBtnAction {
    //下一曲,先处理定时
    self.currentProgress = 0;
    if (self.nextBtnAction) self.nextBtnAction(self.currentSelectTimeIndex);
}

-(void)sliderValueChanged:(UISlider *)slider {
    [Common updataTimerLableWithLable:_beginTime Second:slider.value];
}

- (void)sliderTouchUpInSide:(UISlider *)slider {
    //滑动进度条暂停
    if (slider.value > self.currentProgress) {
        slideStatue = MoveForward;
    }else {
        slideStatue = MoveBack;
    }
    self.currentProgress = slider.value;
    if (self.seekProgress) self.seekProgress(slider.value);
    //设置完进度后更新时间
    if(self.selectTimeZone != SelectTimeZoneTwo) [self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:self.currentModel];
}
#pragma mark - 选择定时时间
- (void)timeBtnSelectAction:(UIButton *)button {
    NSInteger index = button.tag - 100;
    if (index == _timeListNameArray.count - 1) {
        [self timeListMaskViewTapAction];
    }else {
        [self selectClockTimeWithIndex:button.tag - 100];
    }
}
//时间选中后的实现
- (void)timeListMaskViewTapAction {
    _timeListMaskView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self->_timeSelectView.top = XHScreenHeight;
    }completion:^(BOOL finished) {
        //开始计时
        if(self->_oldSelectTimeIndex == self->_currentSelectTimeIndex)return;
        [self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:self.currentModel];
    }];
}

- (void)updataTimeShowWithCurrentTime:(NSInteger)time {
    if (time == 0) {
        [_timeBtn setTitle:@"定时关闭" forState:UIControlStateNormal];
    }else {
        NSString *timertitle = [Common updataTimerLableWithSecond:time];
        [_timeBtn setTitle:timertitle forState:UIControlStateNormal];
    }
    [_timeBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:2];
}
#pragma mark - private
- (void)computationTimeDisplayTimeLableWithSelectZone:(SelectTimeZone)zone NewModel:(ICMusicPlayModel *)model{
    //计算时间
    self.clockTime = (zone == SelectTimeZoneNone) ? 0 : [self totleTimeClockWithIndex:_currentSelectTimeIndex CurrentModel:model ModelArray:self.musicArray];
 if(self.currentClockTime) self.currentClockTime(self.clockTime,zone,self.currentSelectTimeIndex);
}

- (void)selectClockTimeWithIndex:(NSInteger)index{
    if (index == 1) {
        self.selectTimeZone = SelectTimeZoneNone;
    }else if (1 < index && index < 5) {
        self.selectTimeZone = SelectTimeZoneOne;
    }else if (4 < index && index < 8) {
        self.selectTimeZone = SelectTimeZoneTwo;
    }
    if (index < 1 || index > 7 || (_currentSelectTimeIndex == index)) return;
    //其他
    for (NSInteger i = 1; i < _timeListNameArray.count; i++) {
        UIButton *btn = _timeButtonArray[i];
        UIImageView *imageView = _timeImageViewArray[i];
        btn.selected = i == index ? YES : NO;
        imageView.hidden = i == index ? NO : YES;
    }
    //记录选项
    _currentSelectTimeIndex = index;
}

- (void)updateTimeShow {
    NSString *timertitle = [Common updataTimerLableWithSecond:_clockTime];
    [_timeBtn setTitle:timertitle forState:UIControlStateNormal];
    [_timeBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:2];
}

//计算定时
- (NSInteger)totleTimeClockWithIndex:(NSInteger)index CurrentModel:(ICMusicPlayModel *)model ModelArray:(NSArray *)musicArray{
    if (index < 1 || index > 7) return 0;
    NSInteger clockSum = 0;
    if (index > 1 && index < 5) {
        //正常播放完成的去除
        NSInteger newIndex = self.overPlayNum > 0 ? (index - self.overPlayNum) : index;
        for (NSInteger i = 0; i < newIndex - 1; i++) {
            ICMusicPlayModel *playModel = musicArray[i];
            clockSum += playModel.audioLength;
            //如果是正在播放的歌曲，减去当前播放歌曲的进度
            if([self.currentModel.audioUrl isEqualToString: playModel.audioUrl]) clockSum -= self.currentProgress;
        }
    }else if(index == 1){
        clockSum = 0;
    }else {
        clockSum = 600 * (index - 4);
    }
    return clockSum;
}

@end
