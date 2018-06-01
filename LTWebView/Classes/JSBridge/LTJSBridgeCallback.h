//
//  LTJSBridgeCallback.h
//  LTWebView
//
//  Created by Futao on 2018/5/31.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LTJSBridgeWebView.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(JSBridgeCallback)
@interface LTJSBridgeCallback : NSObject

@property (nonatomic, weak,readonly) LTJSBridgeWebView *webView;

@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, assign) BOOL removeAfterExecute;
    
- (id)initWithWebView:(LTJSBridgeWebView *)webView;
- (void)execute;
- (void)executeWithParam:(NSString * _Nullable )param;
- (void)executeWithParams:(NSArray<NSString*> * _Nullable)params;
@end

NS_ASSUME_NONNULL_END

