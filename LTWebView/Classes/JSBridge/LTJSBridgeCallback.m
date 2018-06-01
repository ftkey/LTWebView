//
//  LTJSBridgeCallback.m
//  LTWebView
//
//  Created by Futao on 2018/5/31.
//

#import "LTJSBridgeCallback.h"

@interface LTJSBridgeCallback()
@property (nonatomic, weak) LTJSBridgeWebView *webView;
@end

@implementation LTJSBridgeCallback

- (id)initWithWebView:(LTJSBridgeWebView *)webView{
    self = [super init];
    if (self) {
        self.webView = webView;
    }
    return self;
}

- (void)execute{
    [self executeWithParams:nil];
}
- (void)executeWithParam:(NSString *)param{
    NSArray* params = [NSArray arrayWithObject:param];
    [self executeWithParams:params];
}

- (void)executeWithParams:(NSArray<NSString*> *)params{
    NSMutableString* injection = @"".mutableCopy;
    [injection appendFormat:@"JSB.invokeCallback(\"%@\", %@", self.callbackId, self.removeAfterExecute ? @"true" : @"false"];
    if (params){
        for (int i = 0; i < params.count; i++){
            NSString* arg = [params objectAtIndex:i];
            NSString* encodedArg = [arg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"].invertedSet];
            [injection appendFormat:@", \"%@\"", encodedArg];
        }
    }
    [injection appendString:@");"];
    if (_webView) {
        [_webView evaluateJavaScript:injection completionHandler:nil];
    }
}
@end
