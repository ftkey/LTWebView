//
//  LTJSBridgeWebView.h
//  LTWebView
//
//  Created by Futao on 2018/5/31.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <LTWebView/LTWebView.h>
#import "LTJSBridgeInterface.h"
#import "LTJSBridgeProxy.h"
NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(JSBridgeWebView)
@interface LTJSBridgeWebView : LTWebView
@property (nonatomic, strong ,readonly) LTJSBridgeProxy* proxy;
- (void)addJavascriptInterface:(id<LTJSBridgeInterface>)interface;
@end

NS_ASSUME_NONNULL_END
