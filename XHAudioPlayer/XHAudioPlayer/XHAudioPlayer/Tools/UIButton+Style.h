//
//  UIButton+Style.h
//  DWCoach
//
//  Created by Mxionlly on 2017/6/9.
//  Copyright © 2017年 周玉. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ICButtonEdgeInsetsStyle) {
    ICButtonEdgeInsetsStyleTop,         //图片在上，title在下
    ICButtonEdgeInsetsStyleLeft,        //图片在左，title在右
    ICButtonEdgeInsetsStyleBottom,      //图片在下，title在上
    ICButtonEdgeInsetsStyleRight        //图片在右，title在左
};
@interface UIButton (Style)
//控制图片、title位置用该方法，其他方法不准确
- (void)layoutButtonWithEdgeInsetsStyle:(ICButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

-(void)setLayerCornerColor:(UIColor *)Color cornerRadius:(CGFloat )Radius;

-(void)setLayerCornerRadius:(CGFloat )Radius;



//上下居中，图片在上，文字在下
- (void)verticalCenterImageAndTitle:(CGFloat)spacing;
- (void)verticalCenterImageAndTitle;


//左右居中，文字在左，图片在右
- (void)horizontalCenterTitleAndImage:(CGFloat)spacing;
- (void)horizontalCenterTitleAndImage;

//左右居中，图片在左，文字在右
- (void)horizontalCenterImageAndTitle:(CGFloat)spacing;
- (void)horizontalCenterImageAndTitle;

//文字居中，图片在左边
- (void)horizontalCenterTitleAndImageLeft:(CGFloat)spacing;
- (void)horizontalCenterTitleAndImageLeft;

//文字居中，图片在右边
- (void)horizontalCenterTitleAndImageRight:(CGFloat)spacing;
- (void)horizontalCenterTitleAndImageRight;
@end
