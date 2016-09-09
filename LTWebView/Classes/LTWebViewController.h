//
//  LTWebViewController.h
//  LTWebView
//
//  Created by Futao on 16/9/2.
//  Copyright © 2016年 Futao.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTWebView.h"
NS_ASSUME_NONNULL_BEGIN



NS_SWIFT_NAME(LTWebViewController)
@interface LTWebViewController : UIViewController<LTUIWebViewDelegate,LTWKNavigationDelegate,LTWKScriptMessageHandler>
// UIWebView 、 WKWebView
@property (nonatomic, readonly, strong) LTWebView *webView;
// Not yet implementation
@property (nonatomic, readonly, strong) UIActivityIndicatorView *indicatorView;
// Time out internal. default 15.0
@property(assign, nonatomic) NSTimeInterval timeoutInternal;
// Cache policy. default NSURLRequestUseProtocolCachePolicy
@property(assign, nonatomic) NSURLRequestCachePolicy cachePolicy;

@property (nonatomic,readonly,strong,nullable) NSURL *baseURL;
@property (nonatomic,readonly,strong,nullable) NSString *baseURLTitle;
// Auto load URL title . default YES
@property (nonatomic,assign) BOOL shouldAutoloadRequestTitle;

@property (nonatomic,strong,nullable) NSString *userAgent;
// Background Title. default NO
@property (assign, nonatomic) BOOL showsBackgroundLabel;
// Background Title. default NO
@property (nonatomic,readonly,strong) UIView *retryView;
@property(strong,readonly, nonatomic) UIPanGestureRecognizer* swipePanGesture;


- (__nullable id)loadRequest:(NSURLRequest *)request;

- (void)reload;
- (void)goBack;

- (instancetype)initWithURL:(NSURL *)baseURL type: (LTWebViewType)type title:(NSString * __nullable)title userAgent:(NSString* __nullable)userAgent;
- (instancetype)initWithURL:(NSURL *)baseURL type: (LTWebViewType)type title:(NSString * __nullable)title;

@end
NS_ASSUME_NONNULL_END
