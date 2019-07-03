//
//  ICMusicPlayOpration.h
//  DWTeacher
//
//  Created by icochu on 2018/11/22.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import <UIKit/UIKit.h>
#import "ICMusicPlayModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ICMusicPlayOpration : NSObject

/// Current image url.
@property (nonatomic, strong) NSArray *currentPlayModelArray;

@property (nonatomic, assign) NSInteger currentPlayIndex;

@property(nonatomic, assign) BOOL isLastData;

@property(nonatomic, assign) BOOL isFirstData;

- (ICMusicPlayModel *)playNewMusicQueueWithModelArray:(NSArray *)musicModelArray;

- (ICMusicPlayModel *)playNewMusicQueueWithModelArray:(NSArray *)musicModelArray PlayIndex:(NSInteger)index;

- (ICMusicPlayModel *)getNextModel;

- (ICMusicPlayModel *)getFormerModel;

- (ICMusicPlayModel *)getIndexModelWith:(NSInteger)index;

- (void)removeAllSelectData;
@end

NS_ASSUME_NONNULL_END
