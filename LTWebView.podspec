
Pod::Spec.new do |s|
  s.name         = "LTWebView"
  s.version      = "2.0.1"
  s.summary      = "LTWebView LTWebViewController is a UIWebView/WKWebView Controller ,Cookies/Gesture support . JSBridge Like Android addJavascriptInterface and name. "
  s.homepage     = "https://futao.me/"
  s.license      = "Apache License, Version 2.0"
  s.author       = "Ftkey"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ftkey/LTWebView.git", :tag => "#{s.version}" }
  s.resource  = "LTWebView/Resources/LTWebViewController.bundle"  
  s.frameworks = "Foundation", "UIKit", "WebKit"
  s.requires_arc = true
  s.default_subspecs = 'Core'


  s.subspec "Core" do |ss|
    ss.source_files  = "Classes", "LTWebView/Classes/Core/**/*.{h,m}"
  end
  s.subspec 'JSBridge' do |ss|
    ss.dependency 'LTWebView/Core'
    ss.source_files  = "Classes", "LTWebView/Classes/JSBridge/**/*.{h,m}"
  end


end
