//
//  LTWebCookiesManager.h
//  LTWebView
//
//  Created by Futao on 2018/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef LT_WEBVIEW_COOKIES_STRAGE_KEY_NAME
#define LT_WEBVIEW_COOKIES_STRAGE_KEY_NAME @"lt.webview.last.cookies.strage.key"
#endif


NS_SWIFT_NAME(LTWebCookiesManager)
@interface LTWebCookiesManager : NSObject

+(instancetype)defaultManager;

- (void)setAllowAutoSyncWebCookies:(BOOL)isAuto;
// 这几段方法是可以手动获取cookies并保存,例如登录之后存储,下次启动APP继续是登录状态
// 获取当前系统中已有的Cookies;
- (nullable NSArray<NSHTTPCookie *>*)getCurrentWebCookiesWithBaseURL:(NSURL*)baseURL;
// 获取当前系统中已有的Cookies;
- (nullable NSArray<NSHTTPCookie *>*)getCurrentWebAllCookies;
// 从缓存同步到系统;
- (void)syncWebCookiesFromStorage;
// 从系统存储到缓存;
- (void)syncWebCookiesToStorage;
// 清理Cookies;
- (void)cleanWebCookiesOfStorage;
// 这几段方法是可以手动获取cookies并保存,例如登录之后存储,下次启动APP继续是登录状态
@end


NS_ASSUME_NONNULL_END


