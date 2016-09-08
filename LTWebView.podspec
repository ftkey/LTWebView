
Pod::Spec.new do |s|
  s.name         = "LTWebView"
  s.version      = "1.1"
  s.summary      = "LTWebView LTWebViewController is a UIWebView/WKWebView Controller"
  s.homepage     = "https://futao.me/"
  s.license      = "Apache License, Version 2.0"
  s.author       = "Ftkey"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ftkey/LTWebView.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "LTWebView/Classes/**/*.{h,m}"
  s.resource  = "LTWebView/Resources/LTWebViewController.bundle"  
  s.frameworks = "Foundation", "UIKit", "WebKit"
  s.requires_arc = true
  s.dependency "AXNavigationBackItemInjection"
end
