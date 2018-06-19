/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */


#import "LTUIWebViewDelegate.h"

@implementation LTUIWebViewDelegateImpl
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (instancetype)initWithTitle:(NSString* __nullable)title {
    self = [super init];
    if (self) {
        self.title = title;
        self.estimatedProgress = 0;
    }
    return self;
}
- (BOOL)shouldLoadRequest:(NSURLRequest*)request
{
    NSString* scheme = [[request URL] scheme];
    NSArray* allowedSchemes = [NSArray arrayWithObjects:@"mailto",@"tel",@"blob",@"sms",@"data", nil];
    if([allowedSchemes containsObject:scheme]) {
        return YES;
    }
    else {
        return [NSURLConnection canHandleRequest:request];
    }
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = YES;
    if ([self.forwardDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        shouldLoad =  [self.forwardDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType ];
    }
    return shouldLoad;
}

- (void)webViewDidStartLoad:(UIWebView*)webView
{
    self.estimatedProgress = 0.1;

    if ([self.forwardDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
       return [self.forwardDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    self.estimatedProgress = 1.0;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([self.forwardDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        return [self.forwardDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    self.estimatedProgress = 1.0;
    if ([self.forwardDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        return [self.forwardDelegate webView:webView didFailLoadWithError:error];
    }
}

@end
