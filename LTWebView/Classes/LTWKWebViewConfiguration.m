//
//  LTWKWebViewConfiguration.m
//  LTWebView
//
//  Created by Futao on 16/9/2.
//  Copyright © 2016年 Futao.me. All rights reserved.
//

#import "LTWKWebViewConfiguration.h"

@implementation LTWKProcessPool
+(instancetype)defaultPool {
    static id _defaultPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultPool = [[[self class] alloc] init];
        
    });
    return _defaultPool;
}
@end


@implementation LTWKWebViewConfiguration

+(instancetype)defaultConfiguration {
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.processPool = [LTWKProcessPool defaultPool];
        self.preferences = [[WKPreferences alloc] init];
        self.preferences.minimumFontSize = 10;
        self.preferences.javaScriptEnabled = YES;
        self.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        self.userContentController = [[WKUserContentController  alloc] init];
    }
    return self;
}

@end


