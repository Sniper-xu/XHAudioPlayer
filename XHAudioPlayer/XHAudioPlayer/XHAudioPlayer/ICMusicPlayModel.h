//
//  ICMusicPlayModel.h
//  DWTeacher
//
//  Created by icochu on 2018/11/22.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICMusicPlayModel : NSObject

@property(nonatomic, strong) NSString *audioUrl;       //音频链接

@property(nonatomic, strong) NSString *audioTitle;     //音频标题

@property(nonatomic, strong) NSString *audioPic;       // 音频图片

@property(nonatomic, strong) NSString *columnName;     //音频作者

@property(nonatomic, assign) NSInteger audioLength;     //音频长度

@property(nonatomic, assign) NSInteger isCurrentPlay;          //当前播放 1 是播放 0 不需要当前播放 ,

@property(nonatomic, assign) NSInteger rownum;                //位置


@end

NS_ASSUME_NONNULL_END
