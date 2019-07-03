//
//  ICMusicPlayListVC.h
//  DWTeacher
//
//  Created by icochu on 2018/12/6.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICMusicPlayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICMusicPlayListVC : UIViewController

@property(nonatomic, strong) NSArray *allListModelArray;

@property(nonatomic, strong) ICMusicPlayModel *currentModel;

@property(nonatomic, assign) BOOL isPlaying;

@property(nonatomic, copy) void(^readPlayMusic)(NSInteger currentSelectTimeListIndex,ICMusicPlayModel *model);
@end

NS_ASSUME_NONNULL_END
