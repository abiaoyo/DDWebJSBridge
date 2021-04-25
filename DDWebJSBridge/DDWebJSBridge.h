//
//  DDWebJSBridge.h
//  WKWebViewDemo
//
//  Created by liyebiao on 2021/1/11.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

//js响应方法 - method是要调用的js方法，如果为nil，则默认调用传过来的callback
typedef void (^DDWebJSBridgeResponseBlock)(NSString * _Nullable method,NSDictionary * params);
//js处理方法 -
typedef void (^DDWebJSBridgeHandlerBlock)(NSDictionary * body, NSDictionary * params,DDWebJSBridgeResponseBlock responseBlock);


@interface DDWebJSBridge : NSObject
//创建JSBridge，这里webView.configuration.userContentController需要自己提前创建好且不能为空，channels为通道数组，可以用来做不同模块通道
+ (instancetype)bridgeForWebView:(WKWebView * _Nonnull)webView channels:(NSArray<NSString *> *)channels;
//打印日志
+ (void)LogEnable;
//改变协议的method key
+ (void)SetMethodKey:(NSString * _Nonnull)methodKey;
//改变协议的callback key
+ (void)SetCallbackKey:(NSString * _Nonnull)callbackKey;
//改变协议的params key
+ (void)SetParamsKey:(NSString * _Nonnull)paramsKey;

/// 调用JS方法 - 主动调用
/// @param method 方法名
/// @param params 参数
- (void)callJSMethod:(NSString * _Nonnull)method params:(NSDictionary *)params;

/// 注册JS回调 - 被动接收
/// @param jsHandler 回调
/// @param method 方法名
//- (void)registerJSHandler:(DDWebJSBridgeHandlerBlock _Nonnull)jsHandler method:(NSString * _Nonnull)method;

- (void)registerJSHandler:(DDWebJSBridgeHandlerBlock _Nonnull)jsHandler method:(NSString * _Nonnull)method channel:(NSString * _Nonnull)channel;

/// 注册一批JS回调 - 被动接收
//- (void)registerJSHandlers:(NSDictionary<NSString *,DDWebJSBridgeHandlerBlock> *)jsHandlers;

/// 移除JS回调
/// @param method 方法名
- (void)removeJSHandler:(NSString * _Nonnull)method channel:(NSString * _Nonnull)channel;

/// 使用完后需要销毁
- (void)destory;

@end

/**
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

NS_ASSUME_NONNULL_END
