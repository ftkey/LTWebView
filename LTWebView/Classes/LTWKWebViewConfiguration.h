//
//  LTWKWebViewConfiguration.h
//  NDWebView
//
//  Created by Futao on 16/9/1.
//  Copyright © 2016年 ND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface LTWKProcessPool : WKProcessPool

+(instancetype)defaultPool;

@end

@interface LTWKWebViewConfiguration : WKWebViewConfiguration

+(instancetype)defaultConfiguration;

@end




NS_ASSUME_NONNULL_END
