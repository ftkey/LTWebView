//
//  ViewController.m
//  Demo
//
//  Created by Futao on 16/9/8.
//  Copyright © 2016年 Ftkey. All rights reserved.
//

#import "ViewController2.h"
#import <LTWebView/LTWebViewController.h>
#import <LTWebView/LTJSBridgeWebView.h>

#import "NavtiveInterface.h"

@interface ViewController2 ()
@property (nonatomic, retain) LTJSBridgeWebView* myWebView;

@end

@implementation ViewController2
-(LTJSBridgeWebView *)myWebView{
    if (!_myWebView) {
        _myWebView = [[LTJSBridgeWebView alloc] init];
    }
    return _myWebView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.myWebView.frame = self.view.bounds;
//    self.myWebView.proxy.forwardDelegate = self;
    //    _myWebView.navigationDelegate = self;
    //    _myWebView.UIDelegate = self;
    [self.view addSubview:self.myWebView];
    
    NavtiveInterface* interface = [NavtiveInterface new];
    [self.myWebView addJavascriptInterface:interface];
    
    
    //    NSURL* localHtmURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                          pathForResource:@"test" ofType:@"html"]];
    NSURL* localHtmURL = [NSURL URLWithString:@"http://192.168.6.190:8080"];
    //    if ([self.myWebView respondsToSelector:@selector(loadFileURL:allowingReadAccessToURL:)]) {
    //        [self.myWebView loadFileURL:localHtmURL allowingReadAccessToURL:localHtmURL];
    //    }else {
    NSURLRequest* request = [NSURLRequest requestWithURL:localHtmURL];
    [self.myWebView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
@end
