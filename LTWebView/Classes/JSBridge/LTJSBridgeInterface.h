//
//  LTJSBridgeInterface.h
//  LTWebView
//
//  Created by Futao on 2018/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(JSBridgeInterface)
@protocol LTJSBridgeInterface <NSObject>
- (NSString*)interfaceName;
@end

NS_ASSUME_NONNULL_END
