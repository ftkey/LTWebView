//
//  LTWebCookiesManager.m
//  LTWebView
//
//  Created by Futao on 2018/6/1.
//

#import "LTWebCookiesManager.h"
#import <UIKit/UIKit.h>
@implementation LTWebCookiesManager
+(instancetype)defaultManager {
    static id _defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[[self class] alloc] init];
        
    });
    return _defaultManager;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setAllowAutoSyncWebCookies:(BOOL)isAuto {
    if (isAuto) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}
- (void)onApplicationDidFinishLaunchingNotification:(NSNotification*)sender {
    [self syncWebCookiesFromStorage];
}
- (void)onApplicationWillTerminate:(NSNotification*)sender {
    [self syncWebCookiesToStorage];
}
- (void)applicationDidEnterBackground:(NSNotification*)sender {
    [self syncWebCookiesToStorage];
}
// 获取当前系统中已有的Cookies;
- (nullable NSArray<NSHTTPCookie *>*)getCurrentWebCookiesWithBaseURL:(NSURL*)baseURL {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:baseURL];
    return cookies;
}
// 获取当前系统中已有的Cookies;
- (nullable NSArray<NSHTTPCookie *>*)getCurrentWebAllCookies {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    return cookies;
}

- (void)syncWebCookiesFromStorage {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSData *cookiesOfStorage =  [[NSUserDefaults standardUserDefaults] objectForKey: LT_WEBVIEW_COOKIES_STRAGE_KEY_NAME];
    if (cookiesOfStorage) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesOfStorage];
        if (cookies) {
            for (NSHTTPCookie *cookie in cookies) {
                if ([cookie.name rangeOfString:@"'"].location != NSNotFound) {
                    continue;
                }
                [cookieStorage setCookie:cookie];
            }
        }
    }
    
}

// 存储Cookies;
- (void)syncWebCookiesToStorage {
    NSArray<NSHTTPCookie *> *cookies =  [self getCurrentWebAllCookies];
    if (cookies) {
        NSData *savecookiesData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
        if(savecookiesData){
            [[NSUserDefaults standardUserDefaults] setObject:savecookiesData forKey: LT_WEBVIEW_COOKIES_STRAGE_KEY_NAME];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}
// 清理Cookies;
- (void)cleanWebCookiesOfStorage {
    
    NSHTTPCookieStorage *cookieStrage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStrage cookies]) {
        [cookieStrage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey: LT_WEBVIEW_COOKIES_STRAGE_KEY_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
@end
