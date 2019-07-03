//
//  ICMusicPlayListCell.h
//  DWTeacher
//
//  Created by icochu on 2018/12/6.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMusicPlayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICMusicPlayListCell : UITableViewCell

@property(nonatomic, strong) ICMusicPlayModel *playModel;

@property(nonatomic, assign) BOOL isPlaying;     //是否为播放对象

@property(nonatomic, assign) BOOL playStatue;   //播放状态播放/暂停

@end

NS_ASSUME_NONNULL_END
