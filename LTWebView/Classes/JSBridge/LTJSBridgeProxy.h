//
//  LTJSBridgeProxy.h
//  LTWebView
//
//  Created by Futao on 2018/5/31.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <LTWebView/LTWKNavigationDelegate.h>
#import "LTJSBridgeInterface.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(JSBridgeProxy)
@interface LTJSBridgeProxy : NSObject <LTWKScriptMessageHandler, LTWKNavigationDelegate> {
    NSString *_injectJS;
}
@property (nonatomic, weak ,nullable) id<LTWKScriptMessageHandler, LTWKNavigationDelegate> forwardDelegate;
@property (nonatomic, strong, readonly) NSMutableDictionary<id<LTJSBridgeInterface>,NSString*>* javascriptInterfaces;
- (void)addJavascriptInterface:(id<LTJSBridgeInterface>)interface;
@end
NS_ASSUME_NONNULL_END
