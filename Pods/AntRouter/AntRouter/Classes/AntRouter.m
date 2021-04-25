//
//  AntRouter.m
//  AntRouterDemo
//
//  Created by abiaoyo on 2021/2/26.
//

#import "AntRouter.h"

static BOOL AntRouterRegisterLogEnable = NO;
static BOOL AntRouterCallLogEnable = NO;

#ifdef DEBUG
#define AntRouterLog(format, ...) printf("🍄%s\n", [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define AntRouterLog(format, ...)
#endif


//MARK:AntRouterResponseObject
@interface AntRouterResponseObject : NSObject<AntRouterResponse>
@property (nonatomic,assign) BOOL success;
@property (nonatomic,strong) id object;
@end
@implementation AntRouterResponseObject
+ (AntRouterResponseObject *)resultWithSuccess:(BOOL)success object:(id)object{
    AntRouterResponseObject * result = [AntRouterResponseObject new];
    result.success = success;
    result.object = object;
    return result;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"{success:%@,object:%@}", self.success?@"YES":@"NO",self.object];
}

@end

//MARK:AntRouterNotificationChannel
@interface AntRouterNotificationChannel : NSObject<AntRouterNotificationInterface>
@property (nonatomic,strong) NSMapTable * koMap;
@property (nonatomic,strong) NSMapTable * ohMap;
@end

@implementation AntRouterNotificationChannel

- (instancetype)init{
    self = [super init];
    if (self) {
        self.koMap = [NSMapTable strongToStrongObjectsMapTable];
        self.ohMap = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

- (void)registerKey:(NSString * _Nonnull)key owner:(id _Nonnull)owner handler:(AntRouterResponseBlock _Nonnull)handler{
    if(AntRouterRegisterLogEnable){
        AntRouterLog(@"AntRouter.notification register:%@ owner:%@ handler:%@",key,owner,[(id)handler class]);
    }
    if(!key || !owner || !handler){
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    if(!oTable){
        oTable = [NSHashTable weakObjectsHashTable];
        [self.koMap setObject:oTable forKey:key];
    }
    if(![oTable containsObject:owner]){
        [oTable addObject:owner];
    }
    
    NSMapTable * hMap = [self.ohMap objectForKey:owner];
    if(!hMap){
        hMap = [NSMapTable strongToStrongObjectsMapTable];
        [self.ohMap setObject:hMap forKey:owner];
    }
    [hMap setObject:[handler copy] forKey:key];
}
- (void)postKey:(NSString * _Nonnull)key params:(id _Nullable)params{
    [self postKey:key params:params filter:nil];
}
- (void)postKey:(NSString * _Nonnull)key params:(id _Nullable)params filter:(AntRouterNotificationFilterBlock _Nullable)filter{
    if(AntRouterCallLogEnable){
        AntRouterLog(@"AntRouter.notification post:%@ params:%@ filter:%@",key,params,filter);
    }
    if(!key){
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    for(id owner in oTable.allObjects){
        if(filter){
            if(!filter(owner)){
                continue;
            }
        }
        NSMapTable * hMap = [self.ohMap objectForKey:owner];
        if(hMap){
            AntRouterResponseBlock handler = [hMap objectForKey:key];
            if(handler){
                handler(params);
            }
        }
    }
}
- (void)removeKey:(NSString * _Nonnull)key owner:(id _Nonnull)owner{
    if(!key || !owner){
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    if(oTable && [oTable containsObject:owner]){
        [oTable removeObject:owner];
    }
    NSMapTable * hMap = [self.ohMap objectForKey:owner];
    if(hMap){
        [hMap removeObjectForKey:key];
    }
}
- (void)removeKey:(NSString * _Nonnull)key{
    if(!key){
        return;
    }
    NSHashTable * oTable = [self.koMap objectForKey:key];
    for(id owner in oTable.allObjects){
        NSMapTable * hMap = [self.ohMap objectForKey:owner];
        if(hMap){
            [hMap removeObjectForKey:key];
        }
    }
    [oTable removeAllObjects];
}
- (void)removeAll{
    [self.koMap removeAllObjects];
    [self.ohMap removeAllObjects];
}

@end


//MARK:AntRouterChannel
@interface AntRouterChannel : NSObject<AntRouterInterface>
@property (nonatomic,strong) NSMapTable<NSString *,id> * koMap;
@property (nonatomic,strong) NSMapTable<id,NSMapTable<NSString *,id> *> * omMap;
@property (nonatomic,strong) NSMutableDictionary<NSString *,id> * khMap;
@end
@implementation AntRouterChannel
- (instancetype)init{
    self = [super init];
    if (self) {
        self.koMap = [NSMapTable strongToWeakObjectsMapTable];
        self.omMap = [NSMapTable weakToStrongObjectsMapTable];
        self.khMap = [NSMutableDictionary new];
    }
    return self;
}
- (void)clearOldOwner:(NSString *)key{
    id oldOwner = [self.koMap objectForKey:key];
    if(oldOwner){
        NSMapTable<NSString *,id> * okhMap = [self.omMap objectForKey:oldOwner];
        if(okhMap){
            [okhMap removeObjectForKey:key];
        }
    }
}
- (AntRouterHandler)getHandler:(NSString *)key{
    AntRouterHandler handler = self.khMap[key];
    if(!handler){
        id owner = [self.koMap objectForKey:key];
        if(owner){
            NSMapTable<NSString *,id> * okhMap = [self.omMap objectForKey:owner];
            handler = [okhMap objectForKey:key];
        }
    }
    return handler;
}

//MARK:AntRouterInterface
- (void)registerKey:(NSString * _Nonnull)key owner:(id)owner handler:(AntRouterHandler)handler{
    if(AntRouterRegisterLogEnable){
        AntRouterLog(@"AntRouter.router register:%@ owner:%@ handler:%@",key,owner,[(id)handler class]);
    }
    if(!key || !owner || !handler){
        return;
    }
    [self clearOldOwner:key];
    self.khMap[key] = nil;
    [self.koMap setObject:owner forKey:key];
    NSMapTable<NSString *,id> * okhMap = [self.omMap objectForKey:owner];
    if(okhMap == nil){
        okhMap = [NSMapTable strongToStrongObjectsMapTable];
        [self.omMap setObject:okhMap forKey:owner];
    }
    [okhMap setObject:handler forKey:key];
}
- (void)registerKey:(NSString * _Nonnull)key handler:(AntRouterHandler)handler{
    if(AntRouterRegisterLogEnable){
        AntRouterLog(@"AntRouter.router register:%@ handler:%@",key,[(id)handler class]);
    }
    if(!key || !handler){
        return;
    }
    [self clearOldOwner:key];
    self.khMap[key] = handler;
}
- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key params:(NSDictionary *)params taskBlock:(AntRouterTaskBlock)taskBlock{
    AntRouterHandler handler = nil;
    if(key){
        handler = [self getHandler:key];
    }
    if(handler){
        __block id object = nil;
        handler(params,^(id data){
            object = data;
        },^(id data){
            if(taskBlock){
                taskBlock(data);
            }
        });
        AntRouterResponseObject * response = [AntRouterResponseObject resultWithSuccess:YES object:object];
        if(AntRouterCallLogEnable){
            AntRouterLog(@"AntRouter.router call:%@ params:%@ response:%@",key,params,response);
        }
        return response;
    }
    if(AntRouterCallLogEnable) {
        AntRouterLog(@"AntRouter.router call:%@ params:%@ handler:%@",key,params,handler);
    }
    return [AntRouterResponseObject resultWithSuccess:NO object:nil];
}
- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key params:(NSDictionary *)params{
    return [self callKey:key params:params taskBlock:nil];
}
- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key{
    return [self callKey:key params:nil taskBlock:nil];
}
- (BOOL)canCallKey:(NSString * _Nonnull)key{
    AntRouterHandler handler = [self getHandler:key];
    if(handler){
        return YES;
    }
    return NO;
}
- (void)removeKey:(NSString * _Nonnull)key{
    self.khMap[key] = nil;
    [self clearOldOwner:key];
}
- (void)removeAll{
    [self.khMap removeAllObjects];
    [self.koMap removeAllObjects];
    [self.omMap removeAllObjects];
}
@end




//MARK:AntRouterObjectChannel
@interface AntRouterObjectChannel : NSObject<AntRouterObjectInterface>
@property (nonatomic,strong) NSMapTable<NSString *,id> * koMap;
@property (nonatomic,strong) NSMapTable<id,NSMapTable<NSString *,id> *> * omMap;
@property (nonatomic,strong) NSMutableDictionary<NSString *,id> * khMap;
@end
@implementation AntRouterObjectChannel
- (instancetype)init{
    self = [super init];
    if (self) {
        self.koMap = [NSMapTable strongToWeakObjectsMapTable];
        self.omMap = [NSMapTable weakToStrongObjectsMapTable];
        self.khMap = [NSMutableDictionary new];
    }
    return self;
}
- (void)clearOldOwner:(NSString *)url{
    id oldOwner = [self.koMap objectForKey:url];
    if(oldOwner){
        NSMapTable<NSString *,id> * okhMap = [self.omMap objectForKey:oldOwner];
        if(okhMap){
            [okhMap removeObjectForKey:url];
        }
    }
}
- (AntObjectRouterHandler)getHandler:(NSString *)url{
    AntObjectRouterHandler handler = self.khMap[url];
    if(!handler){
        id owner = [self.koMap objectForKey:url];
        if(owner){
            NSMapTable<NSString *,id> * okhMap = [self.omMap objectForKey:owner];
            handler = [okhMap objectForKey:url];
        }
    }
    return handler;
}

//MARK:AntRouterObjectInterface
- (void)registerKey:(NSString * _Nonnull)key owner:(id)owner handler:(AntObjectRouterHandler)handler{
    if(AntRouterRegisterLogEnable){
        AntRouterLog(@"AntRouter.object register:%@ owner:%@ handler:%@",key,owner,[(id)handler class]);
    }
    if(!key || !owner || !handler){
        return;
    }
    [self clearOldOwner:key];
    self.khMap[key] = nil;
    [self.koMap setObject:owner forKey:key];
    NSMapTable<NSString *,id> * okhMap = [self.omMap objectForKey:owner];
    if(okhMap == nil){
        okhMap = [NSMapTable strongToStrongObjectsMapTable];
        [self.omMap setObject:okhMap forKey:owner];
    }
    [okhMap setObject:handler forKey:key];
}
- (void)registerKey:(NSString * _Nonnull)key handler:(AntObjectRouterHandler)handler{
    if(AntRouterRegisterLogEnable){
        AntRouterLog(@"AntRouter.object register:%@ handler:%@",key,[(id)handler class]);
    }
    if(!key || !handler){
        return;
    }
    [self clearOldOwner:key];
    self.khMap[key] = handler;
}
- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key params:(NSDictionary *)params{
    AntObjectRouterHandler handler = nil;
    if(key){
        handler = [self getHandler:key];
    }
    if(handler){
        id object = handler(params);
        AntRouterResponseObject * response = [AntRouterResponseObject resultWithSuccess:YES object:object];
        if(AntRouterCallLogEnable) {
            AntRouterLog(@"AntRouter.object call:%@ params:%@ response:%@",key,params,response);
        }
        return response;
    }
    if(AntRouterCallLogEnable) {
        AntRouterLog(@"AntRouter.object call:%@ params:%@ handler:%@",key,params,handler);
    }
    return [AntRouterResponseObject resultWithSuccess:NO object:nil];
}
- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key{
    return [self callKey:key params:nil];
}
- (BOOL)canCallKey:(NSString * _Nonnull)key{
    if(!key){
        return NO;
    }
    AntObjectRouterHandler handler = [self getHandler:key];
    if(handler){
        return YES;
    }
    return NO;
}
- (void)removeKey:(NSString * _Nonnull)key{
    if(!key){
        return;
    }
    self.khMap[key] = nil;
    [self clearOldOwner:key];
}
- (void)removeAll{
    [self.khMap removeAllObjects];
    [self.koMap removeAllObjects];
    [self.omMap removeAllObjects];
}
@end

//MARK:AntRouterServiceChannel
@interface AntRouterServiceChannel : NSObject<AntRouterServiceInterface>
@end
@implementation AntRouterServiceChannel

- (NSString *)createKeyWithProtocol:(Protocol *)proto selector:(SEL)selector{
    NSString * protoKey = NSStringFromProtocol(proto);
    NSString * selKey = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@.%@",protoKey,selKey];
}

- (void)registerService:(Protocol *)protocol method:(SEL)method owner:(id)owner handler:(AntRouterHandler)handler{
    NSString * key = [self createKeyWithProtocol:protocol selector:method];
    [AntRouter.router registerKey:key owner:owner handler:handler];
}
- (void)registerService:(Protocol *)protocol method:(SEL)method handler:(AntRouterHandler)handler{
    NSString * key = [self createKeyWithProtocol:protocol selector:method];
    [AntRouter.router registerKey:key handler:handler];
}
- (id<AntRouterResponse>)callService:(Protocol *)protocol method:(SEL)method params:(NSDictionary *)params taskBlock:(AntRouterTaskBlock)taskBlock{
    NSString * key = [self createKeyWithProtocol:protocol selector:method];
    return [AntRouter.router callKey:key params:params taskBlock:taskBlock];
}
- (id<AntRouterResponse>)callService:(Protocol *)protocol method:(SEL)method params:(NSDictionary *)params{
    NSString * key = [self createKeyWithProtocol:protocol selector:method];
    return [AntRouter.router callKey:key params:params];
}
- (id<AntRouterResponse>)callService:(Protocol *)protocol method:(SEL)method{
    NSString * key = [self createKeyWithProtocol:protocol selector:method];
    return [AntRouter.router callKey:key];
}
- (BOOL)canCallService:(Protocol *)protocol method:(SEL)method{
    NSString * key = [self createKeyWithProtocol:protocol selector:method];
    return [AntRouter.router callKey:key];
}
- (void)removeService:(Protocol *)protocol method:(SEL)method{
    NSString * key = [self createKeyWithProtocol:protocol selector:method];
    [AntRouter.router removeKey:key];
}
- (void)removeAll{
    [AntRouter.router removeAll];
}

@end


@implementation AntRouter

+ (id<AntRouterNotificationInterface>)notification{
    static id<AntRouterNotificationInterface> instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AntRouterNotificationChannel new];
    });
    return instance;
}

+ (id<AntRouterInterface>)router{
    static id<AntRouterInterface> instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AntRouterChannel new];
    });
    return instance;
}

+ (id<AntRouterObjectInterface>)object{
    static id<AntRouterObjectInterface> instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AntRouterObjectChannel new];
    });
    return instance;
}

+ (id<AntRouterServiceInterface>)service{
    static id<AntRouterServiceInterface> instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AntRouterServiceChannel new];
    });
    return instance;
}

+ (void)setRegisterLogEnable:(BOOL)enable{
    AntRouterRegisterLogEnable = enable;
}
+ (void)setCallLogEnable:(BOOL)enable{
    AntRouterCallLogEnable = enable;
}

@end
