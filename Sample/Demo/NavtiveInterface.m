//
//  NavtiveObj.m
//  Demo
//
//  Created by Futao on 2018/5/31.
//  Copyright © 2018年 Ftkey. All rights reserved.
//

#import "NavtiveInterface.h"

@implementation NavtiveInterface


/**
 JS交互的对象名称
 
 @return 名称
 */
- (NSString *)interfaceName {
    return @"nativeObj";
}

/**
 保留当前页面，跳转到应用内的某个页面
 @param string （某个页面的url后缀）
 */
- (void)navigateTo:(NSString*)urlPrefix {
    NSLog(@"navigateTo : %@",urlPrefix);

}

/**
 关闭当前页面，返回上一页面或多级页面
 @param string （某个页面的url后缀）
 */
- (void)navigateBack:(NSString*)urlPrefix {
    NSLog(@"navigateBack : %@",urlPrefix);

}

/**
 关闭当前页面，跳转到应用内的某个页面。
 
 @param string （某个页面的url后缀）
 */
- (void)redirectTo:(NSString*)urlPrefix {
    NSLog(@"redirectTo : %@",urlPrefix);

}

/**
 动态设置当前页面的标题。
 
 @param string （某个页面的url后缀）
 */
- (void)setTopBarText:(NSString*)string {
    NSLog(@"setTopBarText : %@",string);

}
@end
