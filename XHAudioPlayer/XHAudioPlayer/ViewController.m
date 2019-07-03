//
//  ViewController.m
//  XHAudioPlayer
//
//  Created by icochu on 2019/6/13.
//  Copyright © 2019 Sniper. All rights reserved.
//

#import "ViewController.h"
#import "ICMusicPlayManager.h"
@interface ViewController ()
@property (nonatomic, strong) ICMusicPlayManager *musicManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    button.backgroundColor = [UIColor cyanColor];
    button.center = self.view.center;
    [button setTitle:@"点击进入" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)buttonAction {
    NSMutableArray *infoModelArray = @[].mutableCopy;
    NSArray *audioURLString = @[@"http://www.ytmp3.cn/down/60673.mp3",@"http://www.ytmp3.cn/down/47045.mp3",@"http://www.ytmp3.cn/down/51866.mp3",@"http://www.ytmp3.cn/down/47043.mp3"];
    NSArray *audioTime = @[@"163",@"197",@"269",@"223"];
    NSArray *audioName = @[@"梦中的婚礼",@"秋日私语",@"故乡原风景",@"卡农"];
    for (NSInteger i = 0; i < audioURLString.count; i++) {
        ICMusicPlayModel *model = [ICMusicPlayModel new];
        model.audioUrl = audioURLString[i];
        model.audioLength = [audioTime[i] integerValue];
        model.audioTitle = audioName[i];
        model.audioPic = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%ld",i] ofType:@"jpg"];
        model.columnName = @"轻音乐";
        model.rownum = i;
        [infoModelArray addObject:model];
    }
    _musicManager = [ICMusicPlayManager sharedManager];
    //准备资源
    [_musicManager loadMusicSouceWithMusicArray:infoModelArray Options:(ICMusicModePlayerOptions){.isNeedCyclePlay = YES,.isShowBackPlayInfo = YES,.playViewY = 100,.playIndex = 0}];
    //开始播放
    [_musicManager beginPlayFirstMusic];
}
@end
