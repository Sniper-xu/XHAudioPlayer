//
//  ICMusicKVOManager.h
//  DWTeacher
//
//  Created by icochu on 2018/11/23.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICMusicKVOManager : NSObject

- (instancetype)initWithTarget:(NSObject *)target;

- (void)safelyAddObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  options:(NSKeyValueObservingOptions)options
                  context:(nullable void *)context;

- (void)safelyRemoveObserver:(NSObject *)observer
                  forKeyPath:(NSString *)keyPath;

- (void)safelyRemoveAllObservers;

@end

NS_ASSUME_NONNULL_END
