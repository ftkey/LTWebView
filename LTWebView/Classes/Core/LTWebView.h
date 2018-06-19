//
//  LTWebView.h
//  LTWebView
//
//  Created by Futao on 16/9/2.
//  Copyright © 2016年 Futao.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "LTUIWebViewDelegate.h"
#import "LTWKWebViewUIDelegate.h"
#import "LTWKNavigationDelegate.h"
#import "LTWKWebViewConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

// 是否支持IOS8的CustomUseragent
#ifndef LT_WEBVIEW_USE_WK_IOS8_CUSTOM_USERAGENT
#define LT_WEBVIEW_USE_WK_IOS8_CUSTOM_USERAGENT 1
#endif


NS_SWIFT_NAME(WebViewType)
typedef NS_ENUM(NSUInteger,LTWebViewType) {
    LTWebViewTypeWKWebView = 0, //使用WKWebView 来实现(如果系统版本已支持WKWebView)
    LTWebViewTypeUIWebView = 1, //使用UIWebView 来实现
    
};
NS_SWIFT_NAME(LTWebView)
@interface LTWebView : UIView
//内部使用的webView,UIWebView or WKWebView
@property (nonatomic,strong ,readonly ) id webView;

@property (nonatomic,weak,nullable) id<LTUIWebViewDelegate> uiWebViewDelegate; // 转发UIWebViewDelegate
@property (nonatomic,weak,nullable) id<LTWKNavigationDelegate> wkNavigationDelegate; // 转发WKNavigationDelegate

@property (nonatomic,strong,nullable) NSString *customUserAgent; //自定义
@property (nonatomic,assign) BOOL isWKWebView;//webView是否为WKWebView

- (instancetype)initWithFrame:(CGRect)frame webViewType: (LTWebViewType) type;
- (nullable id)loadRequest:(NSURLRequest *)request;
- (nullable id)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (nullable id)loadData:(NSData *)data MIMEType:(nullable NSString *)MIMEType textEncodingName:(nullable NSString *)textEncodingName baseURL:(nullable NSURL *)baseURL ;
@property (nullable, nonatomic, readonly, copy)   NSString *title;
@property (nonatomic, readonly, assign) CGFloat estimatedProgress;


@property (nullable, nonatomic, readonly, strong) NSURLRequest *originRequest;
@property (nullable, nonatomic, readonly, strong) NSURL *URL;


- (__nullable id)reload;
- (void)stopLoading;

- (__nullable id)goBack;
- (__nullable id)goForward;

@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

- (void)setJSModelName:(NSString *)jsDataModelName scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler; // 注册JSModelName
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler; // 永远主线程调用

@property (nonatomic) BOOL allowsInlineMediaPlayback; // defaults to YES
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;// defaults to NO，对WKWebView有效
@property (nullable, nonatomic, readonly, strong) UIScrollView *scrollView;
// Clear cache data of web view.
// @param completion completion block.
+ (void)clearWebCacheCompletion:(dispatch_block_t)completion;
//以下针对UIWebView ，如果使用的是WKWebview，相应设置无效
//是否根据视图大小来缩放页面  默认为YES
@property (nonatomic) BOOL scalesPageToFit;

// 通过navigator.userAgent获取UserAgent
- (void)evaluatingNavigatorUserAgentWithCompleted:(void (^)(NSString *userAgent))completed ;
//@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;

@end
NS_ASSUME_NONNULL_END
