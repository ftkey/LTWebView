//
//  NavtiveObj.m
//  Demo
//
//  Created by Futao on 2018/5/31.
//  Copyright © 2018年 Ftkey. All rights reserved.
//

#import "NavtiveInterface.h"

@implementation NavtiveInterface
-(NSString *)interfaceName {
    return @"nativeObj";
}
- (void)navigateTo:(NSString*)string {
    NSLog(@"navigateTo : %@",string);
}

@end
