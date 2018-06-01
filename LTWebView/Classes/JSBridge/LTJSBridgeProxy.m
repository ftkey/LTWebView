//
//  LTJSBridgeProxy.m
//  LTWebView
//
//  Created by Futao on 2018/5/31.
//
#import <objc/runtime.h>
#import <WebKit/WebKit.h>

#import "LTJSBridgeProxy.h"
#import "LTJSBridgeCallback.h"

@interface LTJSBridgeProxy()
@property (nonatomic, strong) NSMutableDictionary* javascriptInterfaces;
@end



@implementation LTJSBridgeProxy
-(NSMutableDictionary *)javascriptInterfaces {
    if (!_javascriptInterfaces) {
        _javascriptInterfaces = [NSMutableDictionary dictionary];
    }
    return _javascriptInterfaces;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        static NSString *lt_jsb_inject_js_base64 = @"d2luZG93LkpTQiA9IHtfX2NhbGxiYWNrczoge30saW52b2tlQ2FsbGJhY2s6IGZ1bmN0aW9uIChjYklELCByZW1vdmVBZnRlckV4ZWN1dGUpe3ZhciBhcmdzID0gQXJyYXkucHJvdG90eXBlLnNsaWNlLmNhbGwoYXJndW1lbnRzKTthcmdzLnNoaWZ0KCk7YXJncy5zaGlmdCgpO2ZvciAodmFyIGkgPSAwLCBsID0gYXJncy5sZW5ndGg7IGkgPCBsOyBpKyspe2FyZ3NbaV0gPSBkZWNvZGVVUklDb21wb25lbnQoYXJnc1tpXSk7fXZhciBjYiA9IEpTQi5fX2NhbGxiYWNrc1tjYklEXTtpZiAocmVtb3ZlQWZ0ZXJFeGVjdXRlKXtKU0IuX19jYWxsYmFja3NbY2JJRF0gPSB1bmRlZmluZWQ7fXJldHVybiBjYi5hcHBseShudWxsLCBhcmdzKTt9LGNhbGw6IGZ1bmN0aW9uIChvYmosIGZ1bmN0aW9uTmFtZSwgYXJncyl7dmFyIGZvcm1hdHRlZEFyZ3MgPSBbXTtmb3IgKHZhciBpID0gMCwgbCA9IGFyZ3MubGVuZ3RoOyBpIDwgbDsgaSsrKXtpZiAodHlwZW9mIGFyZ3NbaV0gPT0gImZ1bmN0aW9uIil7Zm9ybWF0dGVkQXJncy5wdXNoKCJmIik7dmFyIGNiSUQgPSAiX19jYiIgKyAoK25ldyBEYXRlKTtKU0IuX19jYWxsYmFja3NbY2JJRF0gPSBhcmdzW2ldO2Zvcm1hdHRlZEFyZ3MucHVzaChjYklEKTt9ZWxzZXtmb3JtYXR0ZWRBcmdzLnB1c2goInMiKTtmb3JtYXR0ZWRBcmdzLnB1c2goZW5jb2RlVVJJQ29tcG9uZW50KGFyZ3NbaV0pKTt9fXZhciBhcmdTdHIgPSAoZm9ybWF0dGVkQXJncy5sZW5ndGggPiAwID8gIjoiICsgZW5jb2RlVVJJQ29tcG9uZW50KGZvcm1hdHRlZEFyZ3Muam9pbigiOiIpKSA6ICIiKTt2YXIgaWZyYW1lID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgiSUZSQU1FIik7aWZyYW1lLnNldEF0dHJpYnV0ZSgic3JjIiwgImpzYi1qczoiICsgb2JqICsgIjoiICsgZW5jb2RlVVJJQ29tcG9uZW50KGZ1bmN0aW9uTmFtZSkgKyBhcmdTdHIpO2RvY3VtZW50LmRvY3VtZW50RWxlbWVudC5hcHBlbmRDaGlsZChpZnJhbWUpO2lmcmFtZS5wYXJlbnROb2RlLnJlbW92ZUNoaWxkKGlmcmFtZSk7aWZyYW1lID0gbnVsbDt2YXIgcmV0ID0gSlNCLnJldFZhbHVlO0pTQi5yZXRWYWx1ZSA9IHVuZGVmaW5lZDtpZiAocmV0KXtyZXR1cm4gZGVjb2RlVVJJQ29tcG9uZW50KHJldCk7fX0saW5qZWN0OiBmdW5jdGlvbiAob2JqLCBtZXRob2RzKXt3aW5kb3dbb2JqXSA9IHt9O3ZhciBqc09iaiA9IHdpbmRvd1tvYmpdO2ZvciAodmFyIGkgPSAwLCBsID0gbWV0aG9kcy5sZW5ndGg7IGkgPCBsOyBpKyspeyhmdW5jdGlvbiAoKXt2YXIgbWV0aG9kID0gbWV0aG9kc1tpXTt2YXIganNNZXRob2QgPSBtZXRob2QucmVwbGFjZShuZXcgUmVnRXhwKCI6IiwgImciKSwgIiIpO2pzT2JqW2pzTWV0aG9kXSA9IGZ1bmN0aW9uICgpe3JldHVybiBKU0IuY2FsbChvYmosIG1ldGhvZCwgQXJyYXkucHJvdG90eXBlLnNsaWNlLmNhbGwoYXJndW1lbnRzKSk7fTt9KSgpO319fTs=";
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:lt_jsb_inject_js_base64 options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
        _injectJS = decodedString;
        
    }
    return self;
}

- (void)addJavascriptInterface:(id<LTJSBridgeInterface>)interface {
    if (interface) {
        [self.javascriptInterfaces setObject:interface forKey:[interface interfaceName]];
    }
}

#pragma mark WKNavigationDelegate implementation
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURLRequest* request = navigationAction.request;
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString hasPrefix:@"jsb-js:"]) {
        [self handleJsb:webView requestString:requestString];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([self.forwardDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        return [self.forwardDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
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
    [self injectJSScript:webView];
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
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([challenge previousFailureCount] == 0) {
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            } else {
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            }
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView  {
    if ([self.forwardDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)]) {
        if (@available(iOS 9_0, *)) {
            return [self.forwardDelegate webViewWebContentProcessDidTerminate:webView ];
        }
    }
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.forwardDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        return [self.forwardDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}


#pragma 其他处理JS方法
- (void)handleJsb:(WKWebView *)webView requestString:(NSString *)requestString{
 
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    
    NSString* obj = (NSString*)[components objectAtIndex:1];
    NSString* method = [(NSString*)[components objectAtIndex:2]
                        stringByRemovingPercentEncoding];
    
    NSObject* interface = [self.javascriptInterfaces objectForKey:obj];
    
    // execute the interfacing method
    SEL selector = NSSelectorFromString(method);
    NSMethodSignature* sig = [[interface class] instanceMethodSignatureForSelector:selector];
    NSInvocation* invoker = [NSInvocation invocationWithMethodSignature:sig];
    invoker.selector = selector;
    invoker.target = interface;
    
    NSMutableArray* args = [[NSMutableArray alloc] init];
    if ([components count] > 3){
        NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                  stringByRemovingPercentEncoding];
        
        NSArray* formattedArgs = [argsAsString componentsSeparatedByString:@":"];
        for (int i = 0, j = 0, l = (int)[formattedArgs count]; i < l; i+=2, j++){
            NSString* type = ((NSString*) [formattedArgs objectAtIndex:i]);
            NSString* argStr = ((NSString*) [formattedArgs objectAtIndex:i + 1]);
            
            if ([@"f" isEqualToString:type]){
                
                LTJSBridgeCallback* func = [[LTJSBridgeCallback alloc] initWithWebView:(LTJSBridgeWebView*)webView];
                func.callbackId = argStr;
                [args addObject:func];
                [invoker setArgument:&func atIndex:(j + 2)];
            }else if ([@"s" isEqualToString:type]){
                NSString* arg = [argStr stringByRemovingPercentEncoding];
                [args addObject:arg];
                [invoker setArgument:&arg atIndex:(j + 2)];
            }
        }
    }
    
    [invoker invoke];
    
    //return the value by using javascript
    if ([sig methodReturnLength] > 0){
        NSString * __unsafe_unretained tempRetValue;
        [invoker getReturnValue:&tempRetValue];
        NSString *retValue = tempRetValue;
        if (retValue == NULL || retValue == nil){
            [self evaluateJavaScript:@"JSB.retValue=null;" webView:webView];
        }else{
            retValue = [retValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"].invertedSet];
            [self evaluateJavaScript:[@"" stringByAppendingFormat:@"JSB.retValue=\"%@\";", retValue] webView:webView];
        }
    }
}
//向JS中注入交互方法
- (void)injectJSScript:(WKWebView *)webView{
    NSMutableString* injection = [[NSMutableString alloc] init];
    
    //inject the javascript interface
    for(id key in self.javascriptInterfaces) {
        NSObject* interface = [self.javascriptInterfaces objectForKey:key];
        
        [injection appendString:@"JSB.inject(\""];
        [injection appendString:key];
        [injection appendString:@"\", ["];
        
        unsigned int mc = 0;
        Class cls = object_getClass(interface);
        Method * mlist = class_copyMethodList(cls, &mc);
        for (int i = 0; i < mc; i++){
            [injection appendString:@"\""];
            [injection appendString:[NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))]];
            [injection appendString:@"\""];
            
            if (i != mc - 1){
                [injection appendString:@", "];
            }
        }
        
        free(mlist);
        [injection appendString:@"]);"];
    }
    
    NSString* js = _injectJS;
    //inject the basic functions first
    [self evaluateJavaScript:js webView:webView];
    //inject the function interface
    [self evaluateJavaScript:injection webView:webView];
}

- (void)evaluateJavaScript:(NSString *)js webView:(WKWebView *)webView{
    [webView evaluateJavaScript:js completionHandler:nil];
}

- (void)dealloc{
    _javascriptInterfaces = nil;
    _forwardDelegate = nil;
}

@end
