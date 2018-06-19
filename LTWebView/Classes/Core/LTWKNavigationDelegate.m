//
//  LTWKWebViewEngine.m
//  LTWebView
//
//  Created by Futao on 16/9/2.
//  Copyright © 2016年 Futao.me. All rights reserved.
//

#import "LTWKNavigationDelegate.h"

@implementation LTWKNavigationDelegateImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
#pragma mark WKNavigationDelegate implementation
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        return [self.forwardDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else {
        NSURLRequest* request = navigationAction.request;
        NSURL* url = request.URL;
        NSArray *acceptableSchemes = @[
                                       @"tel",@"telprompt",
                                       @"mailto",@"sms",
                                       ];
        if ([url.scheme isEqualToString:@"tel"]) {
            NSString *urlString = [NSString stringWithFormat:@"telprompt://%@", url.relativeString];
            url = [NSURL URLWithString:urlString];
        }
        if ([acceptableSchemes containsObject:url.scheme]) {
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
        return decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        return [self.forwardDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }else {
        return decisionHandler(WKNavigationResponsePolicyAllow);
    }
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        return [self.forwardDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        return [self.forwardDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        return [self.forwardDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didCommitNavigation:)]) {
        return [self.forwardDelegate webView:webView didCommitNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        return [self.forwardDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        return [self.forwardDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        return [self.forwardDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView  {
    if ([self.forwardDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)]) {
        if (@available(iOS 9_0, *)) {
            return [self.forwardDelegate webViewWebContentProcessDidTerminate:webView ];
        }
    }
}
//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
//    if ([self.forwardDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
//        return [self.forwardDelegate userContentController:userContentController didReceiveScriptMessage:message];
//    }
//}


@end
