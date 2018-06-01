//
//  LTWKWebViewCookiesHandler.m
//  Pods
//
//  Created by Futao on 16/9/9.
//
//

#import "LTWKWebViewCookiesHandler.h"

@implementation LTWKWebViewCookiesHandler
+(instancetype)defaultCookiesHandler {
    static id _defaultCookiesHandler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCookiesHandler = [[[self class] alloc] init];
    });
    return _defaultCookiesHandler;
}
- (NSString *)_javascriptStringWithCookie:(NSHTTPCookie*)cookie {
    
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
                        cookie.name,
                        cookie.value,
                        cookie.domain,
                        cookie.path ?: @"/"];
    
    if (cookie.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    
    return string;
}
- (void)addCookieInScriptWithController:(WKUserContentController*)userContentController
{
    NSMutableString* script = [[NSMutableString alloc] init];
    
    // Get the currently set cookie names in javascriptland
    [script appendString:@"var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n"];
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Skip cookies that will break our script
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        
        // Create a line that appends this cookie to the web view's document's cookies
        [script appendFormat:@"if (cookieNames.indexOf('%@') == -1) { document.cookie='%@'; };\n", cookie.name, [self _javascriptStringWithCookie:cookie]];
        
        WKUserScript *cookieInScript = [[WKUserScript alloc] initWithSource:script
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                           forMainFrameOnly:NO];
        [userContentController addUserScript:cookieInScript];
    }
}

- (void)addCookieOutScriptWithController:(WKUserContentController*)userContentController
{
    NSString *sourceString = [NSString stringWithFormat:@"%@%@%@",@"window.webkit.messageHandlers.",kLTWKWebViewCookiesHandlerName,@".postMessage(document.cookie);"];
    __block BOOL isNeedAdd = YES;
    [userContentController.userScripts enumerateObjectsUsingBlock:^(WKUserScript * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.source isEqualToString:sourceString]) {
            isNeedAdd = NO;
        }
        *stop = YES;
    }];
    if (isNeedAdd) {
        WKUserScript *cookieOutScript = [[WKUserScript alloc] initWithSource:sourceString
                                                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                            forMainFrameOnly:NO];
        [userContentController addUserScript:cookieOutScript];
        [userContentController addScriptMessageHandler:self name:kLTWKWebViewCookiesHandlerName];
    }
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if(self.webView) {
        NSArray<NSString*>* cookies = [message.body componentsSeparatedByString:@"; "];
        for (NSString *cookie in cookies) {
            NSArray<NSString *> *comps = [cookie componentsSeparatedByString:@"="];
            if (comps.count < 2) {
                continue;
            }
            NSString* cookieWithURL = [NSString stringWithFormat:@"%@; ORIGINURL=%@", cookie, self.webView.URL];
            NSHTTPCookie* httpCookie = [cookieWithURL ltwebview_cookie];
            if (httpCookie) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:httpCookie];
            }
        }
    }
}
+ (NSURLRequest*)preCookiesRequest:(NSURLRequest*)originalRequest
{
    NSMutableURLRequest *request = [originalRequest mutableCopy];
    NSString *validDomain = request.URL.host;
    const BOOL requestIsSecure = [request.URL.scheme isEqualToString:@"https"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        // Don't even bother with values containing a `'`
        if ([cookie.name rangeOfString:@"'"].location != NSNotFound) {
//            NSLog(@"Skipping %@ because it contains a '", cookie.properties);
            continue;
        }
        
//        // Is the cookie for current domain?
        if (![validDomain hasSuffix:cookie.domain] && ![cookie.domain hasSuffix:validDomain]) {
//            NSLog(@"Skipping %@ (because not %@)", cookie.properties, validDomain);
            continue;
        }
        
        // Are we secure only?
        if (cookie.secure && !requestIsSecure) {
            //NSLog(@"Skipping %@ (because %@ not secure)", cookie.properties, request.URL.absoluteString);
            continue;
        }
        
        NSString *value = [NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value];
        [array addObject:value];
    }
    
    NSString *header = [array componentsJoinedByString:@";"];
    NSLog(@"HEADER: %@",header);
    [request setValue:header forHTTPHeaderField:@"Set-Cookie"];

    return [request copy];
}
@end


@implementation NSString(LTWebViewCookie)

- (NSDictionary *)ltwebview_cookieMap{
    NSMutableDictionary *cookieMap = [NSMutableDictionary dictionary];
    
    NSArray *cookieKeyValueStrings = [self componentsSeparatedByString:@";"];
    for (NSString *cookieKeyValueString in cookieKeyValueStrings) {
        //找出第一个"="号的位置
        NSRange separatorRange = [cookieKeyValueString rangeOfString:@"="];
        
        if (separatorRange.location != NSNotFound &&
            separatorRange.location > 0 &&
            separatorRange.location < ([cookieKeyValueString length] - 1)) {
            //以上条件确保"="前后都有内容，不至于key或者value为空
            
            NSRange keyRange = NSMakeRange(0, separatorRange.location);
            NSString *key = [cookieKeyValueString substringWithRange:keyRange];
            NSString *value = [cookieKeyValueString substringFromIndex:separatorRange.location + separatorRange.length];
            
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [cookieMap setObject:value forKey:key];
            
        }
    }
    return cookieMap;
}



- (NSDictionary *)ltwebview_cookieProperties{
    NSDictionary *cookieMap = [self ltwebview_cookieMap];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    for (NSString *key in [cookieMap allKeys]) {
        
        NSString *value = [cookieMap objectForKey:key];
        NSString *uppercaseKey = [key uppercaseString];//主要是排除命名不规范的问题
        
        if ([uppercaseKey isEqualToString:@"DOMAIN"]) {
            if (![value hasPrefix:@"."] && ![value hasPrefix:@"www"]) {
                value = [NSString stringWithFormat:@".%@",value];
            }
            [cookieProperties setObject:value forKey:NSHTTPCookieDomain];
        }else if ([uppercaseKey isEqualToString:@"VERSION"]) {
            [cookieProperties setObject:value forKey:NSHTTPCookieVersion];
        }else if ([uppercaseKey isEqualToString:@"MAX-AGE"]||[uppercaseKey isEqualToString:@"MAXAGE"]) {
            [cookieProperties setObject:value forKey:NSHTTPCookieMaximumAge];
        }else if ([uppercaseKey isEqualToString:@"PATH"]) {
            [cookieProperties setObject:value forKey:NSHTTPCookiePath];
        }else if([uppercaseKey isEqualToString:@"ORIGINURL"]){
            [cookieProperties setObject:value forKey:NSHTTPCookieOriginURL];
        }else if([uppercaseKey isEqualToString:@"PORT"]){
            [cookieProperties setObject:value forKey:NSHTTPCookiePort];
        }else if([uppercaseKey isEqualToString:@"SECURE"]||[uppercaseKey isEqualToString:@"ISSECURE"]){
            [cookieProperties setObject:value forKey:NSHTTPCookieSecure];
        }else if([uppercaseKey isEqualToString:@"COMMENT"]){
            [cookieProperties setObject:value forKey:NSHTTPCookieComment];
        }else if([uppercaseKey isEqualToString:@"COMMENTURL"]){
            [cookieProperties setObject:value forKey:NSHTTPCookieCommentURL];
        }else if([uppercaseKey isEqualToString:@"EXPIRES"]){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            dateFormatter.dateFormat = @"EEE, dd-MMM-yyyy HH:mm:ss zzz";
            [cookieProperties setObject:[dateFormatter dateFromString:value] forKey:NSHTTPCookieExpires];
        }else if([uppercaseKey isEqualToString:@"DISCART"]){
            [cookieProperties setObject:value forKey:NSHTTPCookieDiscard];
        }else if([uppercaseKey isEqualToString:@"NAME"]){
            [cookieProperties setObject:value forKey:NSHTTPCookieName];
        }else if([uppercaseKey isEqualToString:@"VALUE"]){
            [cookieProperties setObject:value forKey:NSHTTPCookieValue];
        }else{
            [cookieProperties setObject:key forKey:NSHTTPCookieName];
            [cookieProperties setObject:value forKey:NSHTTPCookieValue];
        }
    }
    
    //由于cookieWithProperties:方法properties中不能没有NSHTTPCookiePath，所以这边需要确认下，如果没有则默认为@"/"
    if (![cookieProperties objectForKey:NSHTTPCookiePath]) {
        [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    }
    return cookieProperties;
}

- (NSHTTPCookie *)ltwebview_cookie{
    NSDictionary *cookieProperties = [self ltwebview_cookieProperties];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    return cookie;
}

@end
