//
//  NavtiveObj.h
//  Demo
//
//  Created by Futao on 2018/5/31.
//  Copyright © 2018年 Ftkey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LTWebView/LTJSBridgeCallback.h>
#import <LTWebView/LTJSBridgeInterface.h>

@interface NavtiveInterface : NSObject <LTJSBridgeInterface>
- (NSString *)interfaceName;
- (void)navigateTo:(NSString*)string;

@end
