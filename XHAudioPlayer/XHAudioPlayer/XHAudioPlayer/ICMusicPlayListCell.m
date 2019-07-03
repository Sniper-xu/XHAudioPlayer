//
//  ICMusicPlayListCell.m
//  DWTeacher
//
//  Created by icochu on 2018/12/6.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import "ICMusicPlayListCell.h"
#import "UIView+XHAdd.h"
#import "XHComMacro.h"
#import "Common.h"

@implementation ICMusicPlayListCell{
    UIButton *_playBtn;
    UILabel *_titleLable;
    UILabel *_timeLable;
    UILabel *_nameLable;
    UIImageView *_playImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    _playBtn = [UIButton new];
    _playBtn.top = 20;
    _playBtn.left = 15;
    _playBtn.size = CGSizeMake(27, 27);
    [_playBtn setImage:IMAGE(@"fullView_list_ playBtn_puse") forState:UIControlStateNormal];
    [_playBtn setImage:IMAGE(@"fullView_list_ playBtn_play_1") forState:UIControlStateSelected];
    [self.contentView addSubview:_playBtn];
    
    _playImageView = [UIImageView new];
    _playImageView.frame = _playBtn.frame;
    [self.contentView addSubview:_playImageView];
    
    _titleLable = [UILabel new];
    _titleLable.font = FONT(16);
    _titleLable.textAlignment = NSTextAlignmentLeft;
    _titleLable.top = 14;
    _titleLable.left = _playBtn.right + 10;
    _titleLable.size = CGSizeMake(XHScreenWidth - 67, 20);
    _titleLable.textColor = XHAPPTitleColor;
    _titleLable.numberOfLines = 0;
    [self.contentView addSubview:_titleLable];
    
    _timeLable = [UILabel new];
    _timeLable.font = FONT(14);
    _timeLable.textAlignment = NSTextAlignmentLeft;
    _timeLable.top = _titleLable.bottom + 4;
    _timeLable.left = _titleLable.left;
    _timeLable.size = CGSizeMake(65, 18);
    _timeLable.textColor = XHAPPTipsColor;
    [self.contentView addSubview:_timeLable];
    
    _nameLable = [UILabel new];
    _nameLable.font = FONT(14);
    _nameLable.textAlignment = NSTextAlignmentLeft;
    _nameLable.top = _titleLable.bottom + 4;
    _nameLable.left = _timeLable.right;
    _nameLable.size = CGSizeMake(XHScreenWidth - 120, 18);
    _nameLable.textColor = XHAPPTipsColor;
    [self.contentView addSubview:_nameLable];
}

- (void)setPlayModel:(ICMusicPlayModel *)playModel {
    if (playModel == nil) return;
    _playModel = playModel;
    _titleLable.text = playModel.audioTitle;
    _timeLable.text = [Common updataTimerLableWithSecond:playModel.audioLength];
    _nameLable.text = @"轻音乐";
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (isPlaying) {
        _playBtn.selected = YES;
        _titleLable.textColor = XHAPPMainColor;
        _playImageView.hidden = NO;
        _playBtn.hidden = YES;
        NSMutableArray *imageArr = @[].mutableCopy;
        for (int i = 1; i <= 3; i++) {
            NSString *imageName = [NSString stringWithFormat:@"fullView_list_ playBtn_play_%d",i];
            UIImage *image = IMAGE(imageName);
            [imageArr addObject:image];
        }
        _playImageView.animationImages = imageArr;
        _playImageView.animationDuration = 8.f/20;
        _playImageView.animationRepeatCount = 100000000;
        if (self.playStatue) {
            [_playImageView startAnimating];
        }else {
            _playImageView.image = IMAGE(@"fullView_list_ playBtn_play_1");
        }
    }else {
        _playImageView.hidden = YES;
        _playBtn.selected = NO;
        _playBtn.hidden = NO;
        _titleLable.textColor = XHAPPTitleColor;
    }
}
@end
