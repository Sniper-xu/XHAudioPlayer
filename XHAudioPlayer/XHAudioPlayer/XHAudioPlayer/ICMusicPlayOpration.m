//
//  ICMusicPlayOpration.m
//  DWTeacher
//
//  Created by icochu on 2018/11/22.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import "ICMusicPlayOpration.h"

@implementation ICMusicPlayOpration {
    dispatch_semaphore_t _lock;
}

- (instancetype)init{
    self = [super init];
    _currentPlayModelArray = @[];
    _currentPlayIndex = 0;
    _lock = dispatch_semaphore_create(1);
    return self;
}

- (ICMusicPlayModel *)playNewMusicQueueWithModelArray:(NSArray *)musicModelArray {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _currentPlayIndex = 0;
    _isFirstData = YES;
    _isLastData = (_currentPlayModelArray.count == 1) ? YES : NO;
    _currentPlayModelArray = musicModelArray;
    dispatch_semaphore_signal(_lock);
    ICMusicPlayModel *model;
    for (int i = 0; i < _currentPlayModelArray.count; i++) {
        model = _currentPlayModelArray[i];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i;
            return model;
        }
    }
    return  nil;
}

- (ICMusicPlayModel *)playNewMusicQueueWithModelArray:(NSArray *)musicModelArray PlayIndex:(NSInteger)index {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _currentPlayIndex = index;
    _currentPlayModelArray = musicModelArray;
    _isFirstData = (_currentPlayIndex == 0) ? YES : NO;
    _isLastData = (_currentPlayIndex == _currentPlayModelArray.count - 1) ? YES : NO;
    dispatch_semaphore_signal(_lock);
    ICMusicPlayModel *model;
    for (NSInteger i = index; i < musicModelArray.count; i++) {
        model = musicModelArray[i];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i;
            return model;
        }
    }
    return  nil;
}

- (ICMusicPlayModel *)getNextModel {
    ICMusicPlayModel *model;
    //已经是最后一首没有下一首
    if (_isLastData) return nil;
    for (NSInteger i = _currentPlayIndex + 1; i < _currentPlayModelArray.count; i++) {
        model = _currentPlayModelArray[i];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i;
            _isFirstData = NO;
            _isLastData = (_currentPlayIndex == _currentPlayModelArray.count - 1) ? YES : NO;
            return model;
        }
    }
    return  nil;
}

- (ICMusicPlayModel *)getFormerModel {
    ICMusicPlayModel *model;
    //第一首没有上一首
    if (_isFirstData) return nil;
    for (NSInteger i = _currentPlayIndex; i > 0; i--) {
        model = _currentPlayModelArray[i - 1];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i - 1;
            _isFirstData = (_currentPlayIndex == 0 ) ? YES : NO;
            _isLastData =  NO;
            return model;
        }
    }
    return  nil;
}

- (ICMusicPlayModel *)getIndexModelWith:(NSInteger)index {
    if (index < _currentPlayModelArray.count) {
        ICMusicPlayModel *model = _currentPlayModelArray[index];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = index;
            _isFirstData = (_currentPlayIndex == 0) ? YES : NO;
            _isLastData = (_currentPlayIndex == _currentPlayModelArray.count - 1) ? YES : NO;
            return model;
        }
    }
    return nil;
}

- (void)removeAllSelectData {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _currentPlayIndex = 0;
    _currentPlayModelArray = @[].mutableCopy;
    _isFirstData = YES ;
    _isLastData = YES;
    dispatch_semaphore_signal(_lock);
}
@end
