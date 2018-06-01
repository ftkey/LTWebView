//
//  LTJSBridgeWebView.m
//  LTWebView
//
//  Created by Futao on 2018/5/31.
//

#import "LTJSBridgeWebView.h"
#import <LTJSBridgeProxy.h>
@interface LTJSBridgeWebView()
@property (nonatomic, strong) LTJSBridgeProxy* proxy;
@end


@implementation LTJSBridgeWebView

- (instancetype)init{
    return [self initWithFrame:self.bounds webViewType:LTWebViewTypeWKWebView];
}
- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame webViewType:LTWebViewTypeWKWebView];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder] ;
    if (self) {
        [self _injectJSProxy];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame webViewType: (LTWebViewType) type{
    self = [super initWithFrame:frame webViewType:type];
    if (self) {
        [self _injectJSProxy];
    }
    return self;
}

- (void)_injectJSProxy{
    self.proxy = [[LTJSBridgeProxy alloc] init];
    self.wkNavigationDelegate.forwardDelegate = self.proxy;
}

- (void)addJavascriptInterface:(id<LTJSBridgeInterface>)interface {
    [self.proxy addJavascriptInterface:interface];
}
- (void) dealloc{
    _proxy = nil;
    [self stopLoading];
}
@end


