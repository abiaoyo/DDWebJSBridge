//
//  ViewController.m
//  DDWebJSBridgeDemo
//
//  Created by liyebiao on 2021/4/25.
//

#import "ViewController.h"
#import "DDNewWebViewController.h"
#import "UserInfoViewController.h"

@import AntBus;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakself = self;
    [OCAntBus.callback registerWithKey:@"UserInfo" owner:self handler:^(id _Nullable data, void (^ _Nonnull responseBlock)(id _Nullable)) {
        UserInfoViewController * vctl = [[UserInfoViewController alloc] init];
        [weakself.navigationController pushViewController:vctl animated:YES];
    }];
    [OCAntBus.callback registerWithKey:@"app.location" owner:self handler:^(id _Nullable data, void (^ _Nonnull responseBlock)(id _Nullable)) {
        NSDictionary * location = @{@"latitude":@(30.001233),@"longitude":@(114.001233)};
        responseBlock(location);
    }];
    [OCAntBus.callback registerWithKey:@"loginToken" owner:self handler:^(id _Nullable data, void (^ _Nonnull responseBlock)(id _Nullable)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString * token = [weakself getLoginToken];
            responseBlock(@{@"loginToken":token});
        });
    }];
//    [AntRouter.router registerKey:@"UserInfo" owner:self handler:^(NSDictionary * _Nullable params, AntRouterResponseBlock  _Nonnull responseBlock, AntRouterTaskBlock  _Nullable taskBlock) {
//        UserInfoViewController * vctl = [[UserInfoViewController alloc] init];
//        [weakself.navigationController pushViewController:vctl animated:YES];
//    }];
//    [AntRouter.router registerKey:@"app.location" owner:self handler:^(NSDictionary * _Nullable params, AntRouterResponseBlock  _Nonnull responseBlock, AntRouterTaskBlock  _Nullable taskBlock) {
//        NSDictionary * location = @{@"latitude":@(30.001233),@"longitude":@(114.001233)};
//        responseBlock(location);
//    }];
//    [AntRouter.router registerKey:@"loginToken" owner:self handler:^(NSDictionary * _Nullable params, AntRouterResponseBlock  _Nonnull responseBlock, AntRouterTaskBlock  _Nullable taskBlock) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSString * token = [weakself getLoginToken];
//            taskBlock(@{@"loginToken":token});
//        });
//    }];
}

- (NSString *)getLoginToken{
    return @"SDOjowefwfisfhsi23rew39r3wefskjdfnkwsjfoiw";
}


- (IBAction)clickTestDemo:(id)sender {
    NSURL * url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"summerxx-test" ofType:@"html"]];
    DDNewWebViewController * webVC = [[DDNewWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
