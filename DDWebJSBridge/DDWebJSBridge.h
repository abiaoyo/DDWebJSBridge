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
//创建JSBridge，这里webView.configuration.userContentController需要自己提前创建好且不能为空，channels为频道数组，可以用来做不同模块频道
+ (instancetype)bridgeForWebView:(WKWebView * _Nonnull)webView channels:(NSArray<NSString *> *)channels;
//打印日志
+ (void)LogEnable;
//改变协议的method key
+ (void)SetMethodKey:(NSString * _Nonnull)methodKey;
//改变协议的callback key
+ (void)SetCallbackKey:(NSString * _Nonnull)callbackKey;
//改变协议的params key
+ (void)SetParamsKey:(NSString * _Nonnull)paramsKey;

/// 调用JS方法 - app主动调用
/// @param method 方法名
/// @param params 参数
- (void)callJSMethod:(NSString * _Nonnull)method params:(NSDictionary *)params;

/// 注册JS回调 - 被动接收
/// @param jsHandler 回调
/// @param method 方法名
/// @param channel 频道
- (void)registerJSHandler:(DDWebJSBridgeHandlerBlock _Nonnull)jsHandler method:(NSString * _Nonnull)method channel:(NSString * _Nonnull)channel;

/// 移除JS回调
/// @param method 方法名
/// @param channel 频道
- (void)removeJSHandler:(NSString * _Nonnull)method channel:(NSString * _Nonnull)channel;

/// 使用完后需要销毁
- (void)destory;

@end

NS_ASSUME_NONNULL_END
