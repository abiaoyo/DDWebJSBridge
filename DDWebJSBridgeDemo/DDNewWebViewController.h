//
//  DDNewWebViewController.h
//  WKWebViewDemo
//
//  Created by liyebiao on 2021/1/11.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDNewWebViewController : UIViewController

@property (nonatomic,strong,readonly) WKWebView * webView;
- (instancetype)initWithURL:(NSURL *)url;



@end

NS_ASSUME_NONNULL_END
