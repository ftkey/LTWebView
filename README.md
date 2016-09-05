# LTWebView
LTWebView LTWebViewController is a UIWebView/WKWebView Controller like Wechat

### 支持返回手势，仿微信，参考来源：

https://github.com/devedbox/AXWebViewController

写的真好！这个家伙。


```
NSURL * url = [NSURL URLWithString:@"http://baidu.com"];
   LTWebViewController *detailVc = [[LTWebViewController alloc] initWithURL:url type:LTWebViewTypeUIWebView title:@"XXOO" userAgent:@"IOS"];
    [self.navigationController pushViewController:detailVc animated:YES];
```

```
NSURL * url = [NSURL URLWithString:@"http://baidu.com"];
   LTWebViewController *detailVc = [[LTWebViewController alloc] initWithURL:url type:LTWebViewTypeWKWebView title:@"XXOO" userAgent:@"IOS"];
    [self.navigationController pushViewController:detailVc animated:YES];
```

或者干脆直接使用：LTWebView，完全定制化。