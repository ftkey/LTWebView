//
//  LTWebViewController.m
//  NDWebView
//
//  Created by Futao on 16/9/2.
//  Copyright © 2016年 ND. All rights reserved.
//

#import "LTWebViewController.h"
#ifndef LTWebViewControllerLocalizedString
#define LTWebViewControllerLocalizedString(key, comment) \
NSLocalizedStringFromTableInBundle(key, @"LTWebViewController", [NSBundle bundleWithPath:[[[NSBundle bundleForClass:[LTWebViewController class]] resourcePath] stringByAppendingPathComponent:@"LTWebViewController.bundle"]], comment)
#endif

@interface LTWebViewController () <LTUIWebViewDelegate,LTWKNavigationDelegate,LTWKScriptMessageHandler>
@property (nonatomic, strong) LTWebView *webView;
@property (nonatomic, strong) UIButton *retryView;
@property (nonatomic, assign) LTWebViewType webViewType;
@property (nonatomic,strong) NSURL *lastURL;
/// Navigation back bar button item.
@property(strong, nonatomic) UIBarButtonItem *navigationBackBarButtonItem;
/// Navigation close bar button item.
@property(strong, nonatomic) UIBarButtonItem *navigationCloseBarButtonItem;
/// URL from label.
@property(strong, nonatomic) UILabel *backgroundLabel;
/// Array that hold snapshots of pages.
@property(strong, nonatomic) NSMutableArray* snapshots;
/// Current snapshotview displaying on screen when start swiping.
@property(strong, nonatomic) UIView* currentSnapshotView;
/// Previous snapshotview.
@property(strong, nonatomic) UIView* previousSnapshotView;
/// Background alpha black view.
@property(strong, nonatomic) UIView* swipingBackgoundView;
/// Left pan ges.
@property(strong, nonatomic) UIPanGestureRecognizer* swipePanGesture;
/// If is swiping now.
@property(assign, nonatomic)BOOL isSwipingBack;
@end

@implementation LTWebViewController
- (instancetype)initWithURL:(NSURL *)baseURL type:(LTWebViewType)type title:(NSString * __nullable)title {
    return [self initWithURL:baseURL type:type title:title userAgent:nil];
}

- (instancetype)initWithURL:(NSURL *)baseURL type:(LTWebViewType)type title:(NSString * __nullable)title userAgent:(NSString* __nullable)userAgent {
    if(self = [super init]) {
        _webViewType = LTWebViewTypeWKWebView;
        _timeoutInternal = 15.0;
        _baseURLTitle = title;
        _baseURL = baseURL;
        _userAgent = userAgent;
        _cachePolicy =  NSURLRequestUseProtocolCachePolicy;
        _showsBackgroundLabel = NO;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
    
}
- (void)reloadOriginRequest {
    
}
- (void)reloadCurrentRequest {
    
}
- (void)setupSubviews {
    // Add from label and constraints.
    id topLayoutGuide = self.topLayoutGuide;
    id bottomLayoutGuide = self.bottomLayoutGuide;
    
    // Add web view.
    if (self.webView.isWKWebView) {
        self.webView.frame = self.view.frame;
        [self.view addSubview:self.webView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView, topLayoutGuide, bottomLayoutGuide)]];
        UIView *contentView = _webView.scrollView.subviews.firstObject;
        [contentView addSubview:self.backgroundLabel];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_backgroundLabel(<=width)]" options:0 metrics:@{@"width":@([UIScreen mainScreen].bounds.size.width)} views:NSDictionaryOfVariableBindings(_backgroundLabel)]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-20]];
    }else {
        [self.view insertSubview:self.backgroundLabel atIndex:0];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_backgroundLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundLabel)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-10-[_backgroundLabel]-(>=0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_backgroundLabel, topLayoutGuide)]];
        [self.view addSubview:self.webView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][_webView][bottomLayoutGuide]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView, topLayoutGuide, bottomLayoutGuide)]];
    }
    //
    //
    //    self.progressView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 2);
    //    [self.view addSubview:self.progressView];
    //    [self.view bringSubviewToFront:self.progressView];
}
- (__nullable id)loadRequest:(NSURLRequest *)request{
    self.lastURL = request.URL;
    NSMutableURLRequest *requestMutabled = [request mutableCopy];
    requestMutabled.timeoutInterval = _timeoutInternal;
    requestMutabled.cachePolicy = _cachePolicy;
    if (self.webView.isWKWebView) {
        return [(WKWebView *)_webView loadRequest:requestMutabled];
    }else{
        [(UIWebView *)_webView loadRequest:request];
        return nil;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    if (_baseURL) {
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:_baseURL];
        self.lastURL = _baseURL;
        [self loadRequest:request];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    else {
        
        self.view.backgroundColor = [UIColor colorWithRed:0.180 green:0.192 blue:0.196 alpha:1.00];
        
    }
    _backgroundLabel.textColor = [UIColor colorWithRed:0.180 green:0.192 blue:0.196 alpha:1.00];
    
    [self updateNavigationItems];
    
    // Config navigation item
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateNavigationItems];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationItem setLeftBarButtonItems:nil animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self updateNavigationItems];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if ([super respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    }
    [self updateNavigationItems];
}
- (void)dealloc {
    [_webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (_webView.isWKWebView) {
        _webView.wKUIDelegate = nil;
        _webView.wKNavigationDelegate = nil;
    }else{
        _webView.webViewDelegate = nil;
    }
}
- (void)didStartLoad{
    _backgroundLabel.text = LTWebViewControllerLocalizedString(@"Loading", @"Loading");
    self.navigationItem.title = LTWebViewControllerLocalizedString(@"Loading", @"Loading");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateNavigationItems];
    
}
- (void)didFinishLoad{
    @try {

    } @catch (NSException *exception) {
    } @finally {
    }
    [_retryView removeFromSuperview];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self updateNavigationItems];
    
    NSString *title = [_webView title];
    if (title.length > 10) {
        title = [[title substringToIndex:9] stringByAppendingString:@"…"];
    }
    self.navigationItem.title = title;
    self.navigationItem.title = title?:LTWebViewControllerLocalizedString(@"Browsing the web", @"Browsing the web");
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundle = ([infoDictionary objectForKey:@"CFBundleDisplayName"]?:[infoDictionary objectForKey:@"CFBundleName"])?:[infoDictionary objectForKey:@"CFBundleIdentifier"];
    NSString *host;
    _backgroundLabel.text = [NSString stringWithFormat:@"%@\"%@\"%@.", LTWebViewControllerLocalizedString(@"Web page",@""), host?:bundle, LTWebViewControllerLocalizedString(@"Provided",@"")];
    
}
- (void)didFailLoadWithError:(NSError *)error{
    if (error.code != NSURLErrorCancelled) {
        if (!self.retryView.superview) {
            [self.view addSubview:self.retryView];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_retryView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_retryView)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_retryView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_retryView)]];
        }
    }
    _backgroundLabel.text = [NSString stringWithFormat:@"%@%@",LTWebViewControllerLocalizedString(@"Load failed:", nil) , error.localizedDescription];
    self.navigationItem.title = LTWebViewControllerLocalizedString(@"Load failed", nil);
    [self updateNavigationItems];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // Disable all the '_blank' target in page's target.
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    // Update the items.
    [self updateNavigationItems];
    
    // Call the decision handler to allow to load web page.
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self didStartLoad];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self didFinishLoad];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self didFailLoadWithError:error];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self didFailLoadWithError:error];
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0) {
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    // Should not pop. It appears clicked the back bar button item. We should decide the action according to the content of web view.
    if ([self.navigationController.topViewController isKindOfClass:[LTWebViewController class]]) {
        LTWebViewController* webVC = (LTWebViewController*)self.navigationController.topViewController;
        // If web view can go back.
        if (webVC.webView.canGoBack) {
            // Stop loading if web view is loading.
            if (webVC.webView.isLoading) {
                [webVC.webView stopLoading];
            }
            // Go back to the last page if exist.
            [webVC.webView goBack];
            // Should not pop items.
            return NO;
        }else{
            // Pop view controlers directly.
            return YES;
        }
    }else{
        // Pop view controllers directly.
        return YES;
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // URL actions
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeBackForward: {
            break;
        }
        case UIWebViewNavigationTypeReload: {
            break;
        }
        case UIWebViewNavigationTypeFormResubmitted: {
            break;
        }
        case UIWebViewNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self didStartLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self didFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self didFailLoadWithError:error];
}
-(void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x >= 0) {  //开始动画
            [self startPopSnapshotView];
        }
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapshots lastObject] objectForKey:@"request"];
    
    // 如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    
    UIView* currentSnapshotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    [self.snapshots addObject:
     @{@"request":request,
       @"snapShotView":currentSnapshotView}
     ];
}

-(void)startPopSnapshotView{
    if (self.isSwipingBack) {
        return;
    }
    if (!self.webView.canGoBack) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapshotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapshotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapshotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapshotView.layer.shadowRadius = 5;
    self.currentSnapshotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapshotView.center = center;
    
    self.previousSnapshotView = (UIView*)[[self.snapshots lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.previousSnapshotView.center = center;
    self.previousSnapshotView.alpha = 1;
    self.view.backgroundColor = [UIColor colorWithRed:0.180 green:0.192 blue:0.196 alpha:1.00];
    
    [self.view addSubview:self.previousSnapshotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapshotView];
}

-(void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.view.bounds);
    
    CGPoint currentSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint previousSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    previousSnapshotViewCenter.x -= (boundsWidth - distance)*60/boundsWidth;
    
    self.currentSnapshotView.center = currentSnapshotViewCenter;
    self.previousSnapshotView.center = previousSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (boundsWidth - distance)/boundsWidth;
}

-(void)endPopSnapShotView{
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.view.bounds);
    
    if (self.currentSnapshotView.center.x >= boundsWidth) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapshotView.center = CGPointMake(boundsWidth*3/2, boundsHeight/2);
            self.previousSnapshotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.swipingBackgoundView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.previousSnapshotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapshotView removeFromSuperview];
            [self.webView goBack];
            [self.snapshots removeLastObject];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapshotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.previousSnapshotView.center = CGPointMake(boundsWidth/2-60, boundsHeight/2);
            self.previousSnapshotView.alpha = 1;
        }completion:^(BOOL finished) {
            [self.previousSnapshotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapshotView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}
- (LTWebView *)webView {
    if (_webView) return _webView;
    _webView = [[LTWebView alloc] initWithFrame:CGRectZero webViewType:_webViewType];
    if (_webView.isWKWebView) {
        _webView.wKNavigationDelegate.forwardDelegate = self;
    }else{
        _webView.webViewDelegate.forwardDelegate = self;
    }
    if (_userAgent.length)  _webView.customUserAgent = _userAgent;
    return _webView;
}
- (UILabel *)backgroundLabel {
    if (_backgroundLabel) return _backgroundLabel;
    _backgroundLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _backgroundLabel.textColor = [UIColor colorWithRed:0.322 green:0.322 blue:0.322 alpha:1.00];
    _backgroundLabel.font = [UIFont systemFontOfSize:12];
    _backgroundLabel.numberOfLines = 0;
    _backgroundLabel.textAlignment = NSTextAlignmentCenter;
    _backgroundLabel.backgroundColor = [UIColor clearColor];
    _backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    _backgroundLabel.hidden = !self.showsBackgroundLabel;
    return _backgroundLabel;
}
- (UIButton *)webRetryView {
    if (_retryView) return _retryView;
    _retryView = [UIButton buttonWithType:UIButtonTypeSystem];
    _retryView.backgroundColor = [UIColor whiteColor];
    [_retryView setTitle:LTWebViewControllerLocalizedString(@"Load failed reload", @"Load failed reload") forState:UIControlStateNormal];
    [_retryView setTintColor:[UIColor colorWithRed:0.322 green:0.322 blue:0.322 alpha:1.00]];
    [[_retryView titleLabel] setFont:[UIFont systemFontOfSize:13]];
    _retryView.translatesAutoresizingMaskIntoConstraints = NO;
    [_retryView addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    return _retryView;
}
- (void)reload {
    if (self.lastURL) {
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:_baseURL];
        [self loadRequest:request];
    }
}
- (void)setShowsBackgroundLabel:(BOOL)showsBackgroundLabel {
    _showsBackgroundLabel = showsBackgroundLabel;
    self.backgroundLabel.hidden = !showsBackgroundLabel;
}
- (void)updateNavigationItems {
    [self.navigationItem setLeftBarButtonItems:nil animated:NO];
    if (self.webView.canGoBack) {// Web view can go back means a lot requests exist.
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem, self.navigationBackBarButtonItem, self.navigationCloseBarButtonItem] animated:NO];
        } else {
            [self.navigationItem setLeftBarButtonItems:@[self.navigationCloseBarButtonItem] animated:NO];
        }
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:nil animated:NO];
    }
}
- (void)navigationItemHandleBack:(UIBarButtonItem *)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)navigationIemHandleClose:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIBarButtonItem *)navigationBackBarButtonItem {
    if (_navigationBackBarButtonItem) return _navigationBackBarButtonItem;
    UIImage* backItemImage = [[[UINavigationBar appearance] backIndicatorImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]?:[[UIImage imageNamed:@"LTWebViewController.bundle/backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(backItemImage.size, NO, backItemImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, backItemImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, backItemImage.size.width, backItemImage.size.height);
    CGContextClipToMask(context, rect, backItemImage.CGImage);
    [[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* backItemHlImage = newImage?:[[UIImage imageNamed:@"LTWebViewController.bundle/backItemImage-hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSDictionary *attr = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    if (attr) {
        [backButton setAttributedTitle:[[NSAttributedString alloc] initWithString:LTWebViewControllerLocalizedString(@"Back", @"Back") attributes:attr] forState:UIControlStateNormal];
        UIOffset offset = [[UIBarButtonItem appearance] backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsDefault];
        backButton.titleEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
        backButton.imageEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
    } else {
        [backButton setTitle:LTWebViewControllerLocalizedString(@"Back", @"Back") forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    }
    [backButton setImage:backItemImage forState:UIControlStateNormal];
    [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
    [backButton sizeToFit];
    
    [backButton addTarget:self action:@selector(navigationItemHandleBack:) forControlEvents:UIControlEventTouchUpInside];
    _navigationBackBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return _navigationBackBarButtonItem;
}

- (UIBarButtonItem *)navigationCloseBarButtonItem {
    if (_navigationCloseBarButtonItem) return _navigationCloseBarButtonItem;
    _navigationCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LTWebViewControllerLocalizedString(@"Close", @"Close") style:0 target:self action:@selector(navigationIemHandleClose:)];
    return _navigationCloseBarButtonItem;
}


@end
