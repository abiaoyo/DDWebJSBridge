//
//  DDWebJSBridge.m
//  WKWebViewDemo
//
//  Created by liyebiao on 2021/1/11.
//

#import "DDWebJSBridge.h"
static BOOL LoginEnable = NO;
static NSString * MethodKey = @"method";
static NSString * CallbackKey = @"callback";
static NSString * ParamsKey = @"params";

static NSString * DefaultChannel = @"ddwebjs";
static NSString * DefaultMethod = @"ddwebjs_def_channel";

typedef NS_ENUM(NSUInteger,DDWebJSPriority) {
    DDWebJSPriorityDefault = 0,
    DDWebJSPriorityHigh
};

@interface DDWebJSMessage : NSObject
@property (nonatomic,assign) long messageId;
@property (nonatomic,copy) NSString * message;
@property (nonatomic,assign) DDWebJSPriority priority;
@end
@implementation DDWebJSMessage
- (void)dealloc{
    if(LoginEnable){
        NSLog(@"--- dealloc %@ ---",self.class);
    }
}
- (instancetype)initWithMessageId:(long)messageId message:(NSString *)message priority:(DDWebJSPriority)priority{
    if(self = [super init]){
        self.messageId = messageId;
        self.message = message;
        self.priority = priority;
    }
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@{\n  messageId:%@\n  message:%@\n  priority:%@\n}", self.class,@(self.messageId),self.message,@(self.priority)];
}
@end

@interface DDWebJSBridge()<WKScriptMessageHandler,WKNavigationDelegate>
@property (nonatomic,weak) WKWebView * webView;
@property (nonatomic,weak) NSObject<WKNavigationDelegate> * navigationDelegate;
@property (nonatomic,assign) long uniqueMessageId;
@property (nonatomic,assign) BOOL hasRegisterAppJS;
@property (nonatomic,assign) BOOL didFinishNavigation;
@property (nonatomic,assign) BOOL hasRegisterDefaultChannel;
@property (nonatomic,strong) DDWebJSMessage * runJSMessage;
@property (nonatomic,strong) NSMutableArray<NSString *> * channels;
@property (nonatomic,strong) NSMutableArray<DDWebJSMessage *> * jsMessageDefaultQueue;
@property (nonatomic,strong) NSMutableArray<DDWebJSMessage *> * jsMessageHighQueue;

// <channel,<method,handler>>
@property (nonatomic,strong) NSMutableDictionary<NSString *,NSMutableDictionary<NSString *,DDWebJSBridgeHandlerBlock> *> * jsHandlerContainer;
@end

@implementation DDWebJSBridge

+ (instancetype)bridgeForWebView:(WKWebView *)webView channels:(NSArray<NSString *> *)channels{
    DDWebJSBridge * bridge = [[DDWebJSBridge alloc] init];
    [bridge _setupWebView:webView channels:channels];
    return bridge;
}
+ (void)LogEnable{
    LoginEnable = YES;
}
+ (void)SetMethodKey:(NSString * _Nonnull)methodKey{
    MethodKey = methodKey;
}
+ (void)SetCallbackKey:(NSString * _Nonnull)callbackKey{
    CallbackKey = callbackKey;
}
+ (void)SetParamsKey:(NSString * _Nonnull)paramsKey{
    ParamsKey = paramsKey;
}

+ (NSString *)toJsonByDictionary:(NSDictionary *)dict{
    if(!dict){
        return @"";
    }
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString * json = nil;

    if (!jsonData) {
        NSLog(@"%@", error);
    } else {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return json;
}

- (NSMutableDictionary<NSString *,DDWebJSBridgeHandlerBlock> *)getHandlerContainerWithChannel:(NSString *)channel{
    NSMutableDictionary * handlerContainer = self.jsHandlerContainer[channel];
    if(!handlerContainer){
        handlerContainer = [NSMutableDictionary new];
        self.jsHandlerContainer[channel] = handlerContainer;
    }
    return handlerContainer;
}

- (void)dealloc{
    if(LoginEnable){
        NSLog(@"--- dealloc %@ ---",self.class);
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.jsMessageDefaultQueue = [NSMutableArray new];
        self.jsMessageHighQueue = [NSMutableArray new];
        self.jsHandlerContainer = [NSMutableDictionary new];
        self.channels = [NSMutableArray arrayWithObjects:DefaultChannel,nil];
        __weak typeof(self) weakself = self;
        [self registerJSHandler:^(NSDictionary * _Nonnull params, WKScriptMessage * _Nonnull message, DDWebJSBridgeResponseBlock  _Nonnull responseBlock) {
            weakself.hasRegisterAppJS = YES;
            responseBlock(nil,@{@"success":@1,@"message":@"ddwebjs register success"});
            [weakself runJsMessageQueue];
        } method:DefaultMethod channel:DefaultChannel];
    }
    return self;
}

- (void)_setupWebView:(WKWebView *)webView channels:(NSArray<NSString *> *)channels{
    _webView = webView;
    self.navigationDelegate = _webView.navigationDelegate;
    _webView.navigationDelegate = self;
    if(!self.hasRegisterDefaultChannel){
        self.hasRegisterDefaultChannel = YES;
        if(LoginEnable){
            NSLog(@"ddwebjs register default channel:ddwebjs");
        }
        [_webView.configuration.userContentController addScriptMessageHandler:self name:DefaultChannel];
    }
    
    for(NSString * channel in channels){
        if(![self.channels containsObject:channel]){
            [self.channels addObject:channel];
            if(LoginEnable){
                NSLog(@"ddwebjs register channel:%@",channel);
            }
            [_webView.configuration.userContentController addScriptMessageHandler:self name:channel];
        }
    }
}

- (void)destory{
    for(NSString * channel in self.channels){
        [_webView.configuration.userContentController removeScriptMessageHandlerForName:channel];
    }
    [self.jsMessageHighQueue removeAllObjects];
    [self.jsMessageDefaultQueue removeAllObjects];
    [self.jsHandlerContainer removeAllObjects];
    [self.channels removeAllObjects];
}

- (void)callWithMessage:(NSString *)message priority:(DDWebJSPriority)priority{
    long messageId = ++self.uniqueMessageId;
    DDWebJSMessage * jsMessage = [[DDWebJSMessage alloc] initWithMessageId:messageId message:message priority:priority];
    if(priority == DDWebJSPriorityHigh){
        [self.jsMessageHighQueue addObject:jsMessage];
    }else{
        [self.jsMessageDefaultQueue addObject:jsMessage];
    }
    [self runJsMessageQueue];
}

- (void)callJSMethod:(NSString *)method params:(NSDictionary *)params{
    NSString * jsonParams = [DDWebJSBridge toJsonByDictionary:params];
    NSString * message = [NSString stringWithFormat:@"%@(%@)",method,jsonParams];
    [self callWithMessage:message priority:DDWebJSPriorityDefault];
}

- (void)registerJSHandler:(DDWebJSBridgeHandlerBlock)jsHandler method:(NSString *)method channel:(NSString * _Nonnull)channel{
    if(method && jsHandler){
        NSMutableDictionary<NSString *,DDWebJSBridgeHandlerBlock> * handlerContainer = [self getHandlerContainerWithChannel:channel];
        [handlerContainer setValue:jsHandler forKey:method];
    }
}

- (void)removeJSHandler:(NSString *)method channel:(NSString * _Nonnull)channel{
    if(method){
        NSMutableDictionary<NSString *,DDWebJSBridgeHandlerBlock> * handlerContainer = [self getHandlerContainerWithChannel:channel];
        handlerContainer[method] = nil;
    }
}

- (void)runJsMessageQueue{
    if([[NSThread currentThread] isMainThread]){
        [self _runJsMessageQueue];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _runJsMessageQueue];
        });
    }
}

- (void)_runJsMessageQueue{
    if(self.hasRegisterAppJS || self.didFinishNavigation){
        if(self.runJSMessage){
            return;
        }
        DDWebJSMessage * jsMessage = self.jsMessageHighQueue.firstObject;
        if(jsMessage){
            [self.jsMessageHighQueue removeObject:jsMessage];
        }else{
            jsMessage = self.jsMessageDefaultQueue.firstObject;
            if(jsMessage){
                [self.jsMessageDefaultQueue removeObject:jsMessage];
            }
        }
        if(!jsMessage){
            return;
        }
        self.runJSMessage = jsMessage;
        [self.webView evaluateJavaScript:jsMessage.message completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if(LoginEnable){
                NSLog(@"\nddwebjs: - run jsMessage:%@ \nresult:%@ \nerror:%@",jsMessage,result,error);
            }
        }];
        self.runJSMessage = nil;
        [self runJsMessageQueue];
    }
}

/// MARK: - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSString * channel = message.name;
    NSDictionary * body = message.body;
    if(LoginEnable){
        NSLog(@"ddwebjs message.name:%@",message.name);
        NSLog(@"ddwebjs message.body:%@",message.body);
    }
    if(channel){
        NSString * method = body[MethodKey];
        NSString * callback = body[CallbackKey];
        NSDictionary * params = body[ParamsKey];
        
        if(LoginEnable){
            NSLog(@"ddwebjs: .channel%@ .method:%@ .callback:%@ .params:%@",channel,method,callback,params);
        }
        NSMutableDictionary<NSString *,DDWebJSBridgeHandlerBlock> * handlerContainer = [self getHandlerContainerWithChannel:channel];
        DDWebJSBridgeHandlerBlock jsHandler = handlerContainer[method];
        if(jsHandler){
            __weak typeof(self) weakself = self;
            jsHandler(params,message,^(NSString * method,NSDictionary * params){
                if(method){
                    [weakself callJSMethod:method params:params];
                }else{
                    if(callback){
                        NSString * jsonParams = [DDWebJSBridge toJsonByDictionary:params];
                        NSString * message = [NSString stringWithFormat:@"%@(%@)",callback,jsonParams];
                        [weakself callWithMessage:message priority:DDWebJSPriorityHigh];
                    }
                }
            });
        }
    }
}

//MARK:WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if(self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]){
        [self.navigationDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    if(self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]){
        [self.navigationDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    //如果html js没有主动调用channel:ddwebjs  method:ddwebjs_reg_def_channel，则hasRegisterAppJS为NO,则在didFinishNavigation这里手动打开一次
//    self.hasRegisterAppJS = YES;
    self.didFinishNavigation = YES;
    [self runJsMessageQueue];
    if(self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]){
        [self.navigationDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if(self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)]){
        [self.navigationDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }else{
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

/// MARK: RUNTIME
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:[anInvocation selector]]){
        [anInvocation invokeWithTarget:self.navigationDelegate];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [self.navigationDelegate methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    if([super respondsToSelector:aSelector]){
        return YES;
    }
    if([self.navigationDelegate respondsToSelector:aSelector]){
        return YES;
    }
    return NO;
}

@end
