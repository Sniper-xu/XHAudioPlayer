//
//  XHComMacro.h
//  XHLibraryAnalysis
//
//  Created by icochu on 2019/1/8.
//  Copyright © 2019年 Sniper. All rights reserved.
//

#ifndef XHComMacro_h
#define XHComMacro_h

/**
 * 强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 * 调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 * 示例：
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

//单例
#undef    AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef    DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once(&once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

// 异步主线程执行，不强持有Self
#define XHAsyncOnMainQueue(x) \
__weak typeof(self) weakSelf = self; \
dispatch_async(dispatch_get_main_queue(), ^{ \
typeof(weakSelf) self = weakSelf; \
{x} \
});

//颜色
#define XHUIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:1.0]
#define XHUIColorFromRGBA(rgbValue, a) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:a]

//加载本地图片
#define IMAGE(name)         [UIImage imageNamed:name]

//尺寸
#define XHScreenWidth                   ([[UIScreen mainScreen] bounds].size.width)
#define XHScreenHeight                  ([[UIScreen mainScreen] bounds].size.height)

#define XHIntToString(a)                [NSString stringWithFormat:@"%ld",a]
#define XHIntegerToString(a)            [NSString stringWithFormat:@"%zi", a]
#define FONT(a)             [UIFont systemFontOfSize:a]
#define BFONT(a)            [UIFont boldSystemFontOfSize:a]

//主要颜色值
#define XHAPPClearColor         [UIColor clearColor]
#define XHAPPWhiteColor         [UIColor whiteColor]
#define XHAPPBlackColor         [UIColor blackColor]

#define XHAPPMainColor          XHUIColorFromRGB(0xff5c34)  /**<  APP主颜色（红）  */
#define XHAPPQMainColor         XHUIColorFromRGB(0xfff1ee)

#define XHAPPTipsColor          XHUIColorFromRGB(0xaaaaaa)  //灰色
#define XHAPPSubheadColor       XHUIColorFromRGB(0x5a5a5a)  //深灰色
#define XHAPPBGColor            XHUIColorFromRGB(0xf4f4f4)  /**<  背景颜色  */
#define XHAPPTitleColor         XHUIColorFromRGB(0x323232)  /**<  标题颜色  */
#define XHAPPSeparateColor      XHUIColorFromRGB(0xeaeaea)
#define XHAPPRemarkColor        XHUIColorFromRGB(0xababab)
#define XHAPPLabelTitleColor    XHUIColorFromRGB(0x545454)  /**<  内容颜色  */

// 判断设备
//系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//屏幕百分比以6s为基础
#define XHScreenWidthPercentage(a) (XHScreenWidth*((a)/667.00))
#define XHScreenHeightPercentage(a) (XHScreenHeight *((a)/375.00))

#define IS_IPAD_DEVICE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_DEVICE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define Is_iPhone5s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Is_iPhone6s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define Is_iPhone6sPlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define kIPhoneX ([UIScreen mainScreen].bounds.size.height == 812.0)
#define IS_IOS_9 (NSFoundationVersionNumber>=NSFoundationVersionNumber_iOS_9_0? YES : NO)

#define IS_IPHONE_X CGRectEqualToRect([UIScreen mainScreen].bounds, CGRectMake(0, 0, 375, 812))
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD_DEVICE : NO)
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD_DEVICE : NO)
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !IS_IPAD_DEVICE : NO)
#define IS_IPHONE_X_MORE (IS_IPHONE_X || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max )

#define STATUS_BAR_HIGHT    (IS_IPHONE_X_MORE ? 44: 20)//状态栏
#define NAVI_BAR_HIGHT      (IS_IPHONE_X_MORE ? 88: 64)//导航栏
#define SafeAreaTopAddHeight  (IS_IPHONE_X_MORE ? 24: 0)//导航栏多出的高度
#define SafeAreaTopHeight ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 88.0 : 64.0)
#define SafeAreaBottomHeight ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 34 : 0)

#endif /* XHComMacro_h */
