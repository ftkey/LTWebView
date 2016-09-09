//
//  ViewController.m
//  Demo
//
//  Created by Futao on 16/9/8.
//  Copyright © 2016年 Ftkey. All rights reserved.
//

#import "ViewController.h"
#import "LTWebViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onPush:(id)sender {
    NSURL * url = [NSURL URLWithString:@"https://github.com"];
    LTWebViewController *webVC = [[LTWebViewController alloc] initWithURL:url type:LTWebViewTypeWKWebView title:@"常用电话"];
    
    [self.navigationController pushViewController:webVC animated:YES];
}
@end
