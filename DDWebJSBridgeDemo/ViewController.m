//
//  ViewController.m
//  DDWebJSBridgeDemo
//
//  Created by liyebiao on 2021/4/25.
//

#import "ViewController.h"
#import "DDNewWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)clickTestDemo:(id)sender {
    NSURL * url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"summerxx-test" ofType:@"html"]];
    DDNewWebViewController * webVC = [[DDNewWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
