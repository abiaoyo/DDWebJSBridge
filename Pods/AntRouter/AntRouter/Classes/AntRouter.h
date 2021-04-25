//
//  AntRouter.h
//  AntRouterDemo
//
//  Created by abiaoyo on 2021/2/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//MARK:AntRouterResponse
@protocol AntRouterResponse <NSObject>
@required
- (BOOL)success;
- (id _Nullable)object;
@end

//MARK:AntRouterBlock
typedef void (^AntRouterResponseBlock)(id _Nullable data);
typedef void (^AntRouterTaskBlock)(id _Nullable data);
typedef void (^AntRouterHandler)(NSDictionary * _Nullable params,
                                 AntRouterResponseBlock _Nonnull responseBlock,
                                 AntRouterTaskBlock _Nullable taskBlock);
typedef id _Nullable (^AntObjectRouterHandler)(NSDictionary * _Nullable params);
typedef BOOL (^AntRouterNotificationFilterBlock)(id _Nonnull owner);


//MARK:AntRouterNotificationInterface
@protocol AntRouterNotificationInterface <NSObject>
- (void)registerKey:(NSString * _Nonnull)key
              owner:(id _Nonnull)owner
            handler:(AntRouterResponseBlock _Nonnull)handler;

- (void)postKey:(NSString * _Nonnull)key params:(id _Nullable)params;

- (void)postKey:(NSString * _Nonnull)key params:(id _Nullable)params filter:(AntRouterNotificationFilterBlock _Nullable)filter;

- (void)removeKey:(NSString * _Nonnull)key owner:(id _Nonnull)owner;

- (void)removeKey:(NSString * _Nonnull)key;

- (void)removeAll;
@end



//MARK:AntRouterInterface
@protocol AntRouterInterface <NSObject>

- (void)registerKey:(NSString * _Nonnull)key
                    owner:(id _Nonnull)owner
                  handler:(AntRouterHandler _Nonnull)handler;

- (void)registerKey:(NSString * _Nonnull)key
                  handler:(AntRouterHandler _Nonnull)handler;

- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key
                                params:(NSDictionary * _Nullable)params
                             taskBlock:(AntRouterTaskBlock _Nullable)taskBlock;

- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key
                                params:(NSDictionary * _Nullable)params;

- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key;

- (BOOL)canCallKey:(NSString * _Nonnull)key;

- (void)removeKey:(NSString * _Nonnull)key;

- (void)removeAll;
@end

//MARK:AntRouterObjectInterface
@protocol AntRouterObjectInterface <NSObject>

- (void)registerKey:(NSString * _Nonnull)key
                    owner:(id _Nonnull)owner
                  handler:(AntObjectRouterHandler _Nonnull)handler;

- (void)registerKey:(NSString * _Nonnull)key
                  handler:(AntObjectRouterHandler _Nonnull)handler;

- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key params:(NSDictionary * _Nullable)params;

- (id<AntRouterResponse>)callKey:(NSString * _Nonnull)key;

- (BOOL)canCallKey:(NSString * _Nonnull)key;

- (void)removeKey:(NSString * _Nonnull)key;

- (void)removeAll;
@end

//MARK:AntRouterServiceInterface
@protocol AntRouterServiceInterface <NSObject>
- (void)registerService:(Protocol *)protocol
                 method:(SEL)method
                  owner:(id _Nonnull)owner
                handler:(AntRouterHandler _Nonnull)handler;

- (void)registerService:(Protocol *)protocol
                 method:(SEL)method
                handler:(AntRouterHandler _Nonnull)handler;

- (id<AntRouterResponse>)callService:(Protocol *)protocol
                              method:(SEL)method
                              params:(NSDictionary * _Nullable)params
                           taskBlock:(AntRouterTaskBlock _Nullable)taskBlock;

- (id<AntRouterResponse>)callService:(Protocol *)protocol
                              method:(SEL)method
                              params:(NSDictionary * _Nullable)params;

- (id<AntRouterResponse>)callService:(Protocol *)protocol method:(SEL)method;

- (BOOL)canCallService:(Protocol *)protocol method:(SEL)method;

- (void)removeService:(Protocol *)protocol method:(SEL)method;

- (void)removeAll;
@end


//MARK:AntRouter
@interface AntRouter : NSObject

//Register Log, Default NO
+ (void)setRegisterLogEnable:(BOOL)enable;
//Call Log, Default NO
+ (void)setCallLogEnable:(BOOL)enable;

+ (id<AntRouterNotificationInterface>)notification;
+ (id<AntRouterInterface>)router;
+ (id<AntRouterObjectInterface>)object;
+ (id<AntRouterServiceInterface>)service;

@end

NS_ASSUME_NONNULL_END
