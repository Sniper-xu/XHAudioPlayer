//
//  ICMusicPlayNarrowView.m
//  DWTeacher
//
//  Created by icochu on 2018/11/22.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import "ICMusicPlayNarrowView.h"
#import "AutoScrollLabel.h"
#import "UIView+XHAdd.h"
#import "XHComMacro.h"
#import "Common.h"

@interface ICMusicPlayNarrowView()

@property(nonatomic, strong) UIImageView *bgImageView;

@property(nonatomic, strong) UIButton *leftBtn;

@property(nonatomic, strong) UIButton *playBtn;

@property (nonatomic,strong)CABasicAnimation *basicAnimation;

@property(nonatomic, strong) AutoScrollLabel *titleLable;

@property(nonatomic,strong)UIImageView *imageView;

@property(nonatomic, strong) UILabel *timeLable;

@property(nonatomic, strong) UIButton *closeBtn;

@end

@implementation ICMusicPlayNarrowView

- (instancetype)initWithFrame:(CGRect)frame MusicModel:(ICMusicPlayModel *)model{
    if (self = [super initWithFrame:frame]) {
        _currentPlayModel = model;
        [self initView];
    }
    return self;
}

- (void)initView {
    _bgImageView = [UIImageView new];
    _bgImageView.userInteractionEnabled = YES;
    _bgImageView.left = 0;
    _bgImageView.size = self.frame.size;
    _bgImageView.image = [UIImage imageNamed:@"narrow_bgView"];
    [self addSubview:_bgImageView];
    
    _leftBtn = [UIButton new];
    _leftBtn.left = 9;
    _leftBtn.top = 9.5;
    _leftBtn.size = CGSizeMake(45, 45);
    [_leftBtn setImage:IMAGE(@"narrow_left_btn") forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(leftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftBtn];
    
    _imageView = [UIImageView new];
    _imageView.layer.cornerRadius = 15;
    _imageView.layer.masksToBounds = YES;
    _imageView.size = CGSizeMake(30, 30);
    _imageView.top = 7.5 + 9.5;
    _imageView.left = _leftBtn.right - 5;
    _imageView.image = [UIImage imageWithContentsOfFile:_currentPlayModel.audioPic];
    [self addSubview:_imageView];
    
    _playBtn = [UIButton new];
    _playBtn.frame = _imageView.frame;
    [_playBtn setImage:IMAGE(@"narrow_playBtn_play") forState:UIControlStateNormal];
    [_playBtn setImage:IMAGE(@"narrow_playBtn_puse") forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    
    _titleLable = [[AutoScrollLabel alloc]initWithFrame:CGRectMake(85.5, 17.5, 100, 18)];
    _titleLable.font =FONT(14);
    _titleLable.textColor = XHAPPSubheadColor;
    _titleLable.scrollSpeed = 30;
    _titleLable.textAlignment = NSTextAlignmentLeft;
    _titleLable.fadeLength = 12.f;
    _titleLable.scrollDirection = CBAutoScrollDirectionLeft;
    [_titleLable observeApplicationNotifications];
    _titleLable.text = _currentPlayModel.audioTitle;
    [self addSubview:_titleLable];
    
    _timeLable = [UILabel new];
    _timeLable.left = _titleLable.left;
    _timeLable.size = CGSizeMake(90, 14);
    _timeLable.bottom = _imageView.bottom;
    _timeLable.font = FONT(12);
    _timeLable.textColor = XHAPPTipsColor;
    _timeLable.userInteractionEnabled = YES;
    [Common updataTimerLableWithLable:_timeLable Second:_currentPlayModel.audioLength];
    [self addSubview:_timeLable];
    
    UIView *prisentView = [[UIView alloc]initWithFrame:CGRectMake(82, 0, 110, self.frame.size.height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(_bgImageViewTapAction)];
    [prisentView addGestureRecognizer:tap];
    [self addSubview:prisentView];
    
    _closeBtn = [UIButton new];
    _closeBtn.top = 18.5;
    _closeBtn.size = CGSizeMake(27, 27);
    _closeBtn.right = _bgImageView.right - 16;
    [_closeBtn setImage:IMAGE(@"narrow_close") forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    
}

- (void)leftBtnAction:(UIButton *)button {
    button.selected = !button.selected;
    if(self.leftBtnAction) self.leftBtnAction(button.selected);
}

- (void)_bgImageViewTapAction {
    if(self.bgImageViewTapAction) self.bgImageViewTapAction();
}

- (void)playBtnAction:(UIButton *)button{
    button.selected = !button.selected;
    if(self.playBtnAction) self.playBtnAction(button.selected);
}

- (void)closeButtonAction {
    if(self.closeBtnAction) self.closeBtnAction();
}

- (void)beginImageViewAnimate {
    [self.imageView.layer removeAllAnimations];//移除动画
    self.basicAnimation = nil;
    [self basicAnimation];//开始动画
    self.isRunningAnimate = YES;
    self.closeBtn.hidden = YES;
}

- (void)continueImageViewAnimate {
    _playBtn.selected = NO;
    //得到view当前动画时间偏移量
    CFTimeInterval stopTime = [self.imageView.layer timeOffset];
    //初始化开始时间
    self.imageView.layer.beginTime = 0;
    //初始化时间偏移量
    self.imageView.layer.timeOffset = 0;
    //设置动画速度
    self.imageView.layer.speed = 1;
    //计算时间差
    CFTimeInterval tempTime = [self.imageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - stopTime;
    //重新设置动画开始时间
    self.imageView.layer.beginTime = tempTime;
    self.closeBtn.hidden = YES;
}

- (void)stopImageViewAnimate {
    
    self.closeBtn.hidden = NO;
    
    self.isRunningAnimate = NO;
    _playBtn.selected = YES;
    CFTimeInterval stopTime = [self.imageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    //停止动画，速度设置为0
    self.imageView.layer.speed = 0;
    //设置时间偏移量
    self.imageView.layer.timeOffset = stopTime;
}

- (void)updateNewMusicWithModel:(ICMusicPlayModel *)model IsPlaying:(BOOL)isPlay{
    if (model != nil) {
        _currentPlayModel = model;
        _titleLable.text = model.audioTitle;
        _imageView.image = [UIImage imageWithContentsOfFile:model.audioPic];
        [Common updataTimerLableWithLable:_timeLable Second:model.audioLength];
        _playBtn.selected = !isPlay;
    }
}

- (CABasicAnimation *)basicAnimation {
    if (_basicAnimation == nil) {
        self.basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //旋转一圈时长
        self.basicAnimation.duration = 30;
        //开始动画的起始位置
        self.basicAnimation.fromValue = [NSNumber numberWithInt:0];
        //M_PI是180度
        self.basicAnimation.toValue = [NSNumber numberWithInt:M_PI*2];
        //动画重复次数
        [self.basicAnimation setRepeatCount:NSIntegerMax];
        //播放完毕之后是否逆向回到原来位置
        [self.basicAnimation setAutoreverses:NO];
        //是否叠加（追加）动画效果
        [self.basicAnimation setCumulative:YES];
        //停止动画，速度设置为0
        self.imageView.layer.speed = 1;
        //    self.ImageView.layer.speed = 0;
        [self.imageView.layer addAnimation:self.basicAnimation forKey:@"basicAnimation"];
        
    }
    return _basicAnimation;
}

@end
