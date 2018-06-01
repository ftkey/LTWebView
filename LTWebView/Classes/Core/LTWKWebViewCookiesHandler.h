//
//  LTWKWebViewCookiesHandler.h
//  Pods
//
//  Created by Futao on 16/9/9.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSString(LTWebViewCookie)
- (nullable NSHTTPCookie *)ltwebview_cookie;
@end

static NSString *kLTWKWebViewCookiesHandlerName = @"lt_updateCookies";
@interface LTWKWebViewCookiesHandler : NSObject <WKScriptMessageHandler>
+(instancetype)defaultCookiesHandler;
@property (nonatomic, weak, nullable) WKWebView* webView;

- (void)addCookieInScriptWithController:(WKUserContentController*)userContentController;
- (void)addCookieOutScriptWithController:(WKUserContentController*)userContentController;
+ (NSURLRequest*)preCookiesRequest:(NSURLRequest*)originalRequest;



@end

NS_ASSUME_NONNULL_END
