//
//  ViewController.m
//  DDWebJSBridgeDemo
//
//  Created by liyebiao on 2021/4/25.
//

#import "ViewController.h"
#import "DDNewWebViewController.h"
#import <AntRouter/AntRouter.h>
#import "UserInfoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakself = self;
    [AntRouter.router registerKey:@"UserInfo" owner:self handler:^(NSDictionary * _Nullable params, AntRouterResponseBlock  _Nonnull responseBlock, AntRouterTaskBlock  _Nullable taskBlock) {
        UserInfoViewController * vctl = [[UserInfoViewController alloc] init];
        [weakself.navigationController pushViewController:vctl animated:YES];
    }];
}

- (IBAction)clickTestDemo:(id)sender {
    NSURL * url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"summerxx-test" ofType:@"html"]];
    DDNewWebViewController * webVC = [[DDNewWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
