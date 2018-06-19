//
//  LTWebView.m
//  LTWebView
//
//  Created by Futao on 16/9/2.
//  Copyright © 2016年 Futao.me. All rights reserved.
//

#import "LTWebView.h"
#import "LTUIWebViewDelegate.h"
#import "LTWKWebViewUIDelegate.h"
#import "LTWKNavigationDelegate.h"
#import "LTWKWebViewConfiguration.h"


#if LT_WEBVIEW_USE_WK_IOS8_CUSTOM_USERAGENT
@interface WKWebView (Privates)
@property (copy, setter=_setCustomUserAgent:) NSString *_customUserAgent;
@property (copy, setter=_setApplicationNameForUserAgent:) NSString *_applicationNameForUserAgent;
@property (nonatomic, readonly) NSString *_userAgent;
@end
#endif

@interface LTWebView()
@property (nonatomic,strong ) id webView;
@property (nonatomic,strong) LTUIWebViewDelegateImpl *ltuiWebViewDelegate;
@property (nonatomic,strong) LTWKWebViewUIDelegateImpl *ltwkUIDelegate;//WK的UI 代理
@property (nonatomic,strong) LTWKNavigationDelegateImpl *ltwkNavigationDelegate;//WK的UI 代理
@property (nonatomic,assign) LTWebViewType type;
@property (nonatomic, copy)   NSString     * title;
@property (nonatomic, assign) CGFloat estimatedProgress;

@property (nonatomic, strong) NSMutableURLRequest * originRequest;

@end



@implementation LTWebView
- (void)dealloc {
    if(_isWKWebView)
    {
        WKWebView* webView = _webView;
        [webView removeObserver:self forKeyPath:@"title"];
        [webView removeObserver:self forKeyPath:@"estimatedProgress"];
        self.wkNavigationDelegate = nil;
        webView.navigationDelegate = nil;
        webView.UIDelegate = nil;
        [webView.configuration.userContentController removeAllUserScripts];

    }
    else
    {
        UIWebView* webView = _webView;
        [_ltuiWebViewDelegate removeObserver:self forKeyPath:@"title"];
        [_ltuiWebViewDelegate removeObserver:self forKeyPath:@"estimatedProgress"];
        self.uiWebViewDelegate = nil;
        webView.delegate = nil;
    }
    [_webView scrollView].delegate = nil;
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
    
}
- (instancetype)init{
    return [self initWithFrame:self.bounds webViewType:LTWebViewTypeWKWebView];
}
- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame webViewType:LTWebViewTypeWKWebView];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        _allowsBackForwardNavigationGestures = YES;
        _allowsInlineMediaPlayback           = YES;
        [self setBackgroundColor:[UIColor whiteColor]];
        [self initWKWebView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame webViewType: (LTWebViewType) type{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        _allowsBackForwardNavigationGestures = YES;
        _allowsInlineMediaPlayback           = YES;
        [self setBackgroundColor:[UIColor whiteColor]];
        if (_type == LTWebViewTypeWKWebView) {
            [self initWKWebView];
        }else{
            [self initUIWebView];
        }
    }
    return self;
}

- (void)initWKWebView{
    LTWKWebViewConfiguration* config = [LTWKWebViewConfiguration defaultConfiguration];
    WKWebView * webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    _webView = webView;
    [self addSubview:webView];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [webView setAllowsBackForwardNavigationGestures:self.allowsBackForwardNavigationGestures];
    [[webView configuration] setAllowsInlineMediaPlayback:self.allowsInlineMediaPlayback];
    self.ltwkUIDelegate = [[LTWKWebViewUIDelegateImpl alloc] init];
    self.ltwkNavigationDelegate =  [[LTWKNavigationDelegateImpl alloc] init];
    webView.UIDelegate = self.ltwkUIDelegate;
    webView.navigationDelegate = self.ltwkNavigationDelegate;
    _isWKWebView = YES;
    if (!_webView) {
        [self initUIWebView];
    }
}
- (void)initUIWebView{
    UIWebView * webView = [[UIWebView alloc]initWithFrame:self.bounds];
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    _webView = webView;
    [self addSubview:webView];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [webView setScalesPageToFit:YES];
    [webView setAllowsInlineMediaPlayback:YES];
    self.ltuiWebViewDelegate = [[LTUIWebViewDelegateImpl alloc] init];
    webView.delegate = self.ltuiWebViewDelegate;
    [self.ltuiWebViewDelegate addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.ltuiWebViewDelegate addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    if (@available(iOS 9.0, *)) {
        webView.allowsLinkPreview = YES;
    }
    _isWKWebView = NO;
}
- (void)setCustomUserAgent:(NSString*)customUserAgent {
    if (_isWKWebView) {
        @try {
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
                [_webView setCustomUserAgent:customUserAgent];
            }else{
#if LT_WEBVIEW_USE_WK_IOS8_CUSTOM_USERAGENT
                [_webView _setCustomUserAgent:customUserAgent];
#endif
            }
        }@catch (NSException *exception) { }
    }else {
        @try {
            id webDocumentView = [_webView valueForKey:@"documentView"];
            id webView = [webDocumentView valueForKey:@"webView"];
            
            [webView setCustomUserAgent:customUserAgent];
        }@catch (NSException *exception) { }
    }
}
- (NSString *)customUserAgent {
    if (_isWKWebView) {
        if (@available(iOS 9.0, *)) {
            return [_webView customUserAgent];
        }else {
#if LT_WEBVIEW_USE_WK_IOS8_CUSTOM_USERAGENT
            return [_webView _customUserAgent];
#else
            return @"";
#endif
        }
    }else {
        id webDocumentView = [_webView valueForKey:@"documentView"];
        id webView = [webDocumentView valueForKey:@"webView"];
        return  [webView performSelector:@selector(customUserAgent) withObject:nil];
    }
}
- (void)evaluatingNavigatorUserAgentWithCompleted:(void (^)(NSString *userAgent))completed {
    if (_isWKWebView) {
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];[wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *result, NSError *error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completed(result);
            });
        }];
    }else {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completed(userAgent);
        });
    }
}
-(void)setWkNavigationDelegate:(id<LTWKNavigationDelegate>)wkNavigationDelegate {
    _wkNavigationDelegate = wkNavigationDelegate;
    _ltwkNavigationDelegate.forwardDelegate = wkNavigationDelegate;
}
-(void)setUiWebViewDelegate:(id<LTUIWebViewDelegate>)uiWebViewDelegate {
    _uiWebViewDelegate = uiWebViewDelegate;
    _ltuiWebViewDelegate.forwardDelegate = uiWebViewDelegate;
}
#pragma mark - 属性方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"title"]) {
        self.title = change[NSKeyValueChangeNewKey];
    }
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] floatValue];
    }
}
- (void)setJSModelName:(NSString *)jsModelName scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler {
    if (jsModelName) {
        [((WKWebView *)_webView).configuration.userContentController removeScriptMessageHandlerForName:jsModelName];
        [((WKWebView *)_webView).configuration.userContentController addScriptMessageHandler:scriptMessageHandler name:jsModelName];
    }
}

- (NSURL *)URL{
    if (_isWKWebView) {
        return [(WKWebView *)_webView URL];
    }else{
        return [[(UIWebView *)_webView request] URL];
    }
}
- (BOOL)canGoBack{
    return [_webView canGoBack];
}
- (BOOL)canGoForward{
    return [_webView canGoForward];
}
- (BOOL)isLoading{
    return [_webView isLoading];
}

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback{
    if (allowsInlineMediaPlayback != _allowsInlineMediaPlayback) {
        if (_isWKWebView) {
            [[(WKWebView *)_webView configuration] setAllowsInlineMediaPlayback:allowsInlineMediaPlayback];
        }else{
            [(UIWebView *)_webView setAllowsInlineMediaPlayback:allowsInlineMediaPlayback];
        }
        _allowsBackForwardNavigationGestures = allowsInlineMediaPlayback;
    }
}
- (void)setAllowsBackForwardNavigationGestures:(BOOL)allowsBackForwardNavigationGestures{
    if (_isWKWebView && _allowsBackForwardNavigationGestures != allowsBackForwardNavigationGestures) {
        [(WKWebView *)_webView setAllowsBackForwardNavigationGestures:allowsBackForwardNavigationGestures];
        _allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures;
    }
}
- (UIScrollView *)scrollView{
    return [_webView scrollView];
}
- (void)setScalesPageToFit:(BOOL)scalesPageToFit{
    if(!_isWKWebView)
        ((UIWebView *)_webView).scalesPageToFit = scalesPageToFit;
    else
    {
        if(_scalesPageToFit == scalesPageToFit)
        {
            return;
        }
        
        WKWebView* webView = _webView;
        
        NSString *jScript = @"var meta = document.createElement('meta'); \
        meta.name = 'viewport'; \
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(meta);";
        
        if(scalesPageToFit) {
            WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [webView.configuration.userContentController addUserScript:wkUScript];
        }
        else {
            NSMutableArray* array = [NSMutableArray arrayWithArray:webView.configuration.userContentController.userScripts];
            for (WKUserScript *wkUScript in array) {
                if([wkUScript.source isEqual:jScript])
                {
                    [array removeObject:wkUScript];
                    break;
                }
            }
            for (WKUserScript *wkUScript in array) {
                [webView.configuration.userContentController addUserScript:wkUScript];
            }
        }
    }
    _scalesPageToFit = scalesPageToFit;
    
}
#pragma mark - 公共接口
- (__nullable id)loadRequest:(NSURLRequest *)request{
    if (_isWKWebView) {
        NSMutableURLRequest *mreq = [request mutableCopy];
        _originRequest = mreq;
        return [(WKWebView *)_webView loadRequest:self.originRequest];
    }else{
        NSMutableURLRequest *mreq = [request mutableCopy];
        mreq.HTTPShouldHandleCookies = YES;
        _originRequest = mreq;
        [(UIWebView *)_webView loadRequest:self.originRequest];
        return nil;
    }
}
- (__nullable id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL{
    if (_isWKWebView) {
        return [(WKWebView *)_webView loadHTMLString:string baseURL:baseURL];
    }else{
        [(UIWebView *)_webView loadHTMLString:string baseURL:baseURL];
        return nil;
    }
}

- (__nullable id)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL{
    if (_isWKWebView && [(WKWebView *)_webView respondsToSelector:@selector(loadData:MIMEType:characterEncodingName:baseURL:)]) {
        if (@available(iOS 9.0, *)) {
            return [(WKWebView *)_webView loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
        }else {
            return [(WKWebView *)_webView loadHTMLString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] baseURL:baseURL];
        }
    }else{
        [(UIWebView *)_webView loadData:data MIMEType:MIMEType textEncodingName: textEncodingName baseURL:baseURL];
        return nil;
    }
}

- (__nullable id)reload{
    if (_isWKWebView) {
        return [(WKWebView *)_webView reload];
    }else{
        [(UIWebView *)_webView reload];
        return nil;
    }
}
- (void)stopLoading{
    [_webView stopLoading];
}

- (__nullable id)goBack{
    if (_isWKWebView) {
        return [(WKWebView *)_webView goBack];
    }else{
        [(UIWebView *)_webView goBack];
        return nil;
    }
}
- (__nullable id)goForward{
    if (_isWKWebView) {
        return [(WKWebView *)_webView goForward];
    }else{
        [(UIWebView *)_webView goForward];
        return nil;
    }
}
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler{
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
    else {
        __weak typeof(self) weakSelf = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf _evaluateJavaScript:javaScriptString completionHandler:completionHandler];
        });
    }
}
- (void)_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler {
    if (self.isWKWebView) {
        [(WKWebView *)self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }else{
        NSString * resustString = [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(resustString,nil);
        }
    }
}
+ (void)clearWebCacheCompletion:(dispatch_block_t)completion {
    
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
    NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    
    NSError *error;
    /* iOS8.0 WebView Cache path */
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
    
    /* iOS7.0 WebView Cache path */
    [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
    if (completion) {
        completion();
    }
}
@end



