//
//  LTWebView.h
//  JDMEForIphone
//
//  Created by NiuDu on 2016/4/26.
//  Copyright © 2016年 NiuDu All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "LTUIWebViewDelegate.h"
#import "LTWKWebViewUIDelegate.h"
#import "LTWKNavigationDelegate.h"
#import "LTWKWebViewConfiguration.h"
NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(WebViewType)
typedef NS_ENUM(NSUInteger,LTWebViewType) {
    LTWebViewTypeWKWebView = 0, //使用WKWebView 来实现(如果系统版本已支持WKWebView)
    LTWebViewTypeUIWebView = 1, //使用UIWebView 来实现
    
};

NS_SWIFT_NAME(LTWebView)
@interface LTWebView : UIView
//内部使用的webView,UIWebView or WKWebView
@property (nonatomic,strong) id webView;
@property (nonatomic,strong,nullable) LTUIWebViewDelegate *webViewDelegate;
@property (nonatomic,strong,nullable) LTWKWebViewUIDelegate *wKUIDelegate;//WK的UI 代理
@property (nonatomic,strong,nullable) LTWKNavigationDelegate *wKNavigationDelegate;//WK的UI 代理

@property (nonatomic,strong,nullable) NSString *customUserAgent; //自定义
@property (nonatomic,assign) BOOL isWKWebView;//webView是否为WKWebView

- (instancetype)initWithFrame:(CGRect)frame webViewType: (LTWebViewType) type;
- (nullable id)loadRequest:(NSURLRequest *)request;
- (nullable id)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
- (nullable id)loadData:(NSData *)data MIMEType:(nullable NSString *)MIMEType textEncodingName:(nullable NSString *)textEncodingName baseURL:(nullable NSURL *)baseURL;
@property (nullable, nonatomic, readonly, copy)   NSString *title;
@property (nullable, nonatomic, readonly, strong) NSURLRequest *originRequest;
@property (nullable, nonatomic, readonly, strong) NSURLRequest *currentRequest;

@property (nullable, nonatomic, copy,getter = jsDataModelName)   NSString * jsDataModelName;//js注入数据的数据模型，在wkwebView 上有效
- (__nullable id)reload;
- (void)stopLoading;

- (__nullable id)goBack;
- (__nullable id)goForward;

@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler;

@property (nonatomic) BOOL allowsInlineMediaPlayback; // defaults to YES
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;// defaults to NO，对WKWebView有效
@property (nullable, nonatomic, readonly, strong) UIScrollView *scrollView;
// Clear cache data of web view.
//
// @param completion completion block.
+ (void)clearWebCacheCompletion:(dispatch_block_t)completion;


//UIWebView 与WKWebview 设置cookie的方法不同
//@para array中存放的是需要设置的cookie值,类型为NSString类型  。domain表示设置cookie的域，UIWebView需要使用此值
- (void)setCookieWithCooksArray:(NSArray<NSString*> *)array domain: (NSString *) domain forRequest: (NSMutableURLRequest *) request;

//以下针对UIWebView ，如果使用的是WKWebview，相应设置无效
//是否根据视图大小来缩放页面  默认为YES
@property (nonatomic) BOOL scalesPageToFit;
//@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;

@end
NS_ASSUME_NONNULL_END
