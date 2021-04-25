//
//  DDNewWebViewController.m
//  WKWebViewDemo
//
//  Created by liyebiao on 2021/1/11.
//

#import "DDNewWebViewController.h"
#import "DDWebJSBridge.h"
#import <AntRouter/AntRouter.h>

@interface DDNewWebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong) NSURL * url;
@property (nonatomic,strong) WKWebView * webView;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) DDWebJSBridge * jsBridge;
@end

@implementation DDNewWebViewController

- (void)dealloc{
    NSLog(@"--- dealloc %@ ---",self);
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [self.jsBridge destory];
}

- (instancetype)initWithURL:(NSURL *)url{
    if(self = [super init]){
        self.url = url;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupData];
    [self setupSubviews];
    
    /**
     协议组成：
     channel: 频道， 一般是同一个，也可多个
     
     method: 方法
     
     callback: 回调，app处理method完成后，H5需要被调用的方法;
     如果responseBlock中又重新指定了非nil的method方法，则callback不会被调用。
     如：[self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params,
            DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
            responseBlock(@"locationResult",@{@"city":@"earth"});
        } method:@"location" channel:@"testFunc"];
     
     params: 参数
     
     html js 中可调用以下方法注册默认通道
     window.onload = function(){
         window.webkit.messageHandlers.ddwebjs.postMessage({method:'ddwebjs_reg_def_channel'});
     }
     //例：这里是调用app的 getUserInfo方法
     function getUserInfoFromApp(){
        window.webkit.messageHandlers.ioschannel.postMessage({method:'getUserInfo',callback:"refreshUserInfo",params:{userId:1234}});
     }
     */

    /**
     eg:
     __weak typeof(self) weakself = self;
     //打开日志
     [DDWebJSBridge LogEnable];
     
     //创建jsBridge
     self.jsBridge = [DDWebJSBridge bridgeForWebView:self.webView channels:@[@"ddwebview",@"navigation"]];
     
     [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
         responseBlock(nil,@{@"suc":@1,@"msg":@"分享成功"});
     } method:@"share"];
     
     [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
         [weakself.navigationController popViewControllerAnimated:YES];
     } method:@"back"];
     
     // app 调用 js: play方法
     [self.jsBridge callJSMethod:@"play" params:@{@"id":@1001,@"title":@"音乐001",@"url":@"https://www.bdisss.com/v/ddd/asjfow01.mp4"}];
     
     [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
     */
    
    __weak typeof(self) weakself = self;
    [DDWebJSBridge LogEnable];
    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        [weakself.navigationController popViewControllerAnimated:YES];
    } method:@"back" channel:@"navigation"];

    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        responseBlock(nil,@{@"suc":@1,@"msg":@"分享成功"});
    } method:@"share" channel:@"testFunc"];
    
    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        responseBlock(nil,@{@"code":@"xsIhdLA=AU+Ufe1nKW02"});
    } method:@"scan" channel:@"testFunc"];
    
    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        NSDictionary * location = [AntRouter.router callKey:@"app.location"].object;
        responseBlock(nil,location);
    } method:@"location" channel:@"testFunc"];

    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        NSArray<NSNumber *> * color = params[@"color"];
        UIColor * rgbColor = [UIColor colorWithRed:color[0].integerValue/255.0 green:color[1].integerValue/255.0 blue:color[2].integerValue/255.0 alpha:color[3].floatValue];
        weakself.navigationController.navigationBar.backgroundColor = rgbColor;
    } method:@"color" channel:@"testFunc"];

    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        responseBlock(nil,@{@"msg":@"可以支付"});
    } method:@"pay" channel:@"testFunc"];
    
    [self.jsBridge callJSMethod:@"play" params:@{@"id":@1001,@"title":@"音乐001",@"url":@"https://www.bdisss.com/v/ddd/asjfow01.mp4"}];
    
    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        [AntRouter.router callKey:@"UserInfo"];
    } method:@"UserInfo" channel:@"AntRouter"];
    
    [self.jsBridge registerJSHandler:^(NSDictionary * _Nonnull body, NSDictionary * _Nonnull params, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
        NSLog(@"正在登录..");
        [AntRouter.router callKey:@"loginToken" params:params taskBlock:^(id  _Nullable data) {
            NSString * loginToken = data[@"loginToken"];
            responseBlock(nil,@{@"loginToken":loginToken,@"msg":@"登录成功!"});
        }];
    } method:@"loginToken" channel:@"AntRouter"];
        
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)setupData{
    
}

- (void)setupSubviews{
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
}

//MARK:KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        if (self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//MARK:WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}
  // 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
  [self.progressView setProgress:0.0f animated:NO];
}
  // 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
  // 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"self:%@  - didFinishNavigation",self.class);
//  [self getCookie];
}
  //提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  [self.progressView setProgress:0.0f animated:NO];
}
 // 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}
  // 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  
  NSString * urlStr = navigationAction.request.URL.absoluteString;
  NSLog(@"发送跳转请求：%@",urlStr);
  //自己定义的协议头
  NSString *htmlHeadString = @"github://";
  if([urlStr hasPrefix:htmlHeadString]){
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通过截取URL调用OC" message:@"你想前往我的Github主页?" preferredStyle:UIAlertControllerStyleAlert];
      [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
      }])];
      [alertController addAction:([UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          NSURL * url = [NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@"github://callName_?" withString:@""]];
          [[UIApplication sharedApplication] openURL:url];
      }])];
      [self presentViewController:alertController animated:YES completion:nil];
      decisionHandler(WKNavigationActionPolicyCancel);
  }else{
      decisionHandler(WKNavigationActionPolicyAllow);
  }
}
  
  // 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
  NSString * urlStr = navigationResponse.response.URL.absoluteString;
  NSLog(@"当前跳转地址：%@",urlStr);
  //允许跳转
  decisionHandler(WKNavigationResponsePolicyAllow);
  //不允许跳转
  //decisionHandler(WKNavigationResponsePolicyCancel);
}
  //需要响应身份验证时调用 同样在block中需要传入用户身份凭证
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
//  //用户身份信息
//  NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
//  //为 challenge 的发送方提供 credential
//  [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
//  completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
//}
  //进程被终止时调用 (当WKWebView总体内存占用过大，页面即将白屏的时候，系统会调用)
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [webView reload];
}

//MARK:WKUIDelegate
/**
    *  web界面中有弹出警告框时调用
    *
    *  @param webView           实现该代理的webview
    *  @param message           警告框中的内容
    *  @param completionHandler 警告框消失调用
    */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的弹出框" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
   [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       completionHandler();
   }])];
   [self presentViewController:alertController animated:YES completion:nil];
}
   // 确认框
   //JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
   [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       completionHandler(NO);
   }])];
   [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       completionHandler(YES);
   }])];
   [self presentViewController:alertController animated:YES completion:nil];
}
   // 输入框
   //JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
   [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
       textField.text = defaultText;
   }];
   [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       completionHandler(alertController.textFields[0].text?:@"");
   }])];
   [self presentViewController:alertController animated:YES completion:nil];
}
   // 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
   if (!navigationAction.targetFrame.isMainFrame) {
       [webView loadRequest:navigationAction.request];
   }
   return nil;
}

//MARK: Getter
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, CGRectGetMinY(self.webView.frame), self.view.bounds.size.width, 3);
        _progressView.trackTintColor = UIColor.grayColor;
        _progressView.progressTintColor = UIColor.blueColor;
    }
    return _progressView;
}

- (DDWebJSBridge *)jsBridge{
    if(!_jsBridge){
        _jsBridge = [DDWebJSBridge bridgeForWebView:self.webView channels:@[@"navigation",@"testFunc",@"AntRouter"]];
    }
    return _jsBridge;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
        config.allowsInlineMediaPlayback = YES;
        WKUserContentController * userController = [[WKUserContentController alloc] init];
        config.userContentController = userController;
//        [config.userContentController addScriptMessageHandler:self name:@"ddwebview"];
        /// 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        /// 最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 40.0;
        /// 设置是否支持javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        /// 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        WKWebView * v = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        v.allowsBackForwardNavigationGestures = YES;
        v.navigationDelegate = self;
        v.UIDelegate = self;
        v.opaque = NO;
        v.backgroundColor = UIColor.whiteColor;
        [v addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
        _webView = v;
    }
    return _webView;
}

@end

