//
//  Common.h
//  XHAudioPlayer
//
//  Created by icochu on 2019/6/13.
//  Copyright © 2019 Sniper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Common : NSObject

//展示时间
+ (void)updataTimerLableWithLable:(UILabel *)lable Second:(NSInteger)time;

//转换时间
+ (NSString *)updataTimerLableWithSecond:(NSInteger)time;

@end

NS_ASSUME_NONNULL_END
