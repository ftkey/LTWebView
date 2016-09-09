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
#if LT_WKWebView_USE_Shared_Cookies
#import "LTWKWebViewCookiesHandler.h"
#endif

@import WebKit;
@interface WKWebView (Privates)
@property (copy, setter=_setCustomUserAgent:) NSString *_customUserAgent;
@property (copy, setter=_setApplicationNameForUserAgent:) NSString *_applicationNameForUserAgent;
@property (nonatomic, readonly) NSString *_userAgent;
@end

@interface LTWebView()
@property (nonatomic,assign)  LTWebViewType type;
@property (nonatomic, copy)   NSString     * title;

@property (nonatomic, strong) NSMutableURLRequest * originRequest;

@end



@implementation LTWebView
#define LTWebView_IS_IOS9_AND_HIGHER   ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
- (void)dealloc
{
    if(_isWKWebView)
    {
        WKWebView* webView = _webView;
#if LT_WKWebView_USE_Shared_Cookies
        [[LTWKWebViewCookiesHandler defaultCookiesHandler] setWebView:nil];
#endif
        [webView removeObserver:self forKeyPath:@"title"];
        [self setWKUIDelegate:nil];
        [self setWKNavigationDelegate:nil];
        webView.navigationDelegate = nil;
        webView.UIDelegate = nil;

    }
    else
    {
        UIWebView* webView = _webView;
        [self setWebViewDelegate:nil];
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
#if LT_WKWebView_USE_Shared_Cookies
    [[LTWKWebViewCookiesHandler defaultCookiesHandler] setWebView:webView];
    [[LTWKWebViewCookiesHandler defaultCookiesHandler] addCookieOutScriptWithController:config.userContentController];
//    [[LTWKWebViewCookiesHandler defaultCookiesHandler] addCookieInScriptWithController:config.userContentController];
#endif
    _webView = webView;
    [self addSubview:webView];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [webView setAllowsBackForwardNavigationGestures:self.allowsBackForwardNavigationGestures];
    [[webView configuration] setAllowsInlineMediaPlayback:self.allowsInlineMediaPlayback];
    self.wKUIDelegate = [[LTWKWebViewUIDelegate alloc] init];
    self.wKNavigationDelegate =  [[LTWKNavigationDelegate alloc] init];
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
    self.webViewDelegate = [[LTUIWebViewDelegate alloc] init];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    webView.allowsLinkPreview = YES;
#endif
    _isWKWebView = NO;
}
- (void)setCustomUserAgent:(NSString*)customUserAgent {
    if (_isWKWebView) {
        @try {
            if (LTWebView_IS_IOS9_AND_HIGHER) {
                [_webView setCustomUserAgent:customUserAgent];
            }else{
                [_webView _setCustomUserAgent:customUserAgent];
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
        if (LTWebView_IS_IOS9_AND_HIGHER) {
            return [_webView customUserAgent];
        }else{
           return [_webView _customUserAgent];
        }
    }else {
        id webDocumentView = [_webView valueForKey:@"documentView"];
        id webView = [webDocumentView valueForKey:@"webView"];
        return [webView customUserAgent];
    }
}
- (void)setCookieWithCooksArray:(NSArray<NSString*> *)array domain: (NSString *) domain forRequest: (NSMutableURLRequest *) request {
    
    __block NSString * cookieForDocument = @"";
    __block NSString * cookieForHeader   = @"";
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if (_isWKWebView) {
                cookieForDocument = [cookieForDocument stringByAppendingString:[NSString stringWithFormat:@"document.cookie = '%@';",obj]];
                cookieForHeader = [cookieForHeader stringByAppendingString:[NSString stringWithFormat:@"%@;",obj]];
            }else{
                NSHTTPCookie *cookie_temp = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:obj, NSHTTPCookieName,
                                                                                @"", NSHTTPCookieValue,
                                                                                domain, NSHTTPCookieDomain,
                                                                                @"/", NSHTTPCookiePath,
                                                                                [NSDate distantFuture], NSHTTPCookieExpires,
                                                                                nil]];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie_temp];
                
            }
            
        }
    }];
    if (_isWKWebView) {
        if ([cookieForHeader hasSuffix:@";"]) {
            cookieForHeader = [cookieForHeader substringToIndex:cookieForHeader.length-1];
        }
        
        [request addValue:cookieForHeader forHTTPHeaderField:@"Cookie"];
        if ([cookieForDocument hasSuffix:@";"]) {
            cookieForDocument = [cookieForDocument substringToIndex:cookieForDocument.length-1];
        }
        NSLog(@"cookieForHeader=======%@",cookieForHeader);
        NSLog(@"cookieForDocument======%@",cookieForDocument);
        WKUserScript * cookieScript = [[WKUserScript alloc]initWithSource:cookieForDocument injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [((WKWebView *)self.webView).configuration.userContentController addUserScript:cookieScript];
    }
}

- (void)setWKUIDelegate:(LTWKWebViewUIDelegate *)wKUIDelegate {
    _wKUIDelegate = wKUIDelegate;
    ((WKWebView *)_webView).UIDelegate = wKUIDelegate;
}
- (void)setWKNavigationDelegate:(LTWKNavigationDelegate *)wKNavigationDelegate {
    _wKNavigationDelegate = wKNavigationDelegate;
    ((WKWebView *)_webView).navigationDelegate = wKNavigationDelegate;
}
- (void)setWebViewDelegate:(LTUIWebViewDelegate *)webViewDelegate {
    if (_webViewDelegate) {
        [_webViewDelegate removeObserver:self forKeyPath:@"title"];
    }
    _webViewDelegate = webViewDelegate;
    ((UIWebView *)_webView).delegate = webViewDelegate;
    if (_webViewDelegate) {
        [_webViewDelegate addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - 属性方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"title"]) {
        self.title = change[NSKeyValueChangeNewKey];
    }
}
- (void)setJsDataModelName: (NSString *) jsDataModelName{
    if (jsDataModelName.length > 0 && [_jsDataModelName isEqualToString:jsDataModelName] && _webView && [_webView isMemberOfClass:[WKWebView class]]) {
        [((WKWebView *)_webView).configuration.userContentController addScriptMessageHandler:self.wKNavigationDelegate name:jsDataModelName];
        _jsDataModelName = jsDataModelName;
    }else{
        _jsDataModelName = nil;
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
        
        if(scalesPageToFit)
        {
            WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [webView.configuration.userContentController addUserScript:wkUScript];
        }
        else
        {
            NSMutableArray* array = [NSMutableArray arrayWithArray:webView.configuration.userContentController.userScripts];
            for (WKUserScript *wkUScript in array)
            {
                if([wkUScript.source isEqual:jScript])
                {
                    [array removeObject:wkUScript];
                    break;
                }
            }
            for (WKUserScript *wkUScript in array)
            {
                [webView.configuration.userContentController addUserScript:wkUScript];
            }
        }
    }
    
    _scalesPageToFit = scalesPageToFit;
    
}
#pragma mark - 公共接口
- (__nullable id)loadRequest:(NSURLRequest *)request{
    if (_isWKWebView) {
#if LT_WKWebView_USE_Shared_Cookies
        NSMutableURLRequest *mreq = [[LTWKWebViewCookiesHandler preCookiesRequest:request] mutableCopy];
#else
        NSMutableURLRequest *mreq = [request mutableCopy];
#endif
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
        return [(WKWebView *)_webView loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
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
    if (_isWKWebView) {
        [(WKWebView *)_webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }else{
        NSString * resustString = [(UIWebView *)_webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(resustString,nil);
        }
    }
}
+ (void)clearWebCacheCompletion:(dispatch_block_t)completion {
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:completion];
    
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
