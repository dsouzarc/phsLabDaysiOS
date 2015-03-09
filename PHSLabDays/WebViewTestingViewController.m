//
//  WebViewTestingViewController.m
//  PHSLabDays
//
//  Created by Ryan D'souza on 3/5/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "WebViewTestingViewController.h"

@interface WebViewTestingViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewTestingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"UserAgent": @"Mozilla/5.0 (iPad; CPU OS 8_1_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) CriOS/40.0.2214.69 Mobile/12B440 Safari/600.1.4 (000452)  " }];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://pschool.princetonk12.org"]]];
}

int counter = 0;

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"\n\nHere %i", counter);
    [self.webView stringByEvaluatingJavaScriptFromString:@"ConfigureLoginBox('Student')"];
    
    NSString *loadUsernameJS = [NSString stringWithFormat:@"document.getElementsByName('account')[0].value='RDsouza'"];
    NSString *loadPasswordJS = [NSString stringWithFormat:@"document.getElementsByName('pw')[0].value='ryaniscool96'"];
    
    //autofill the form
    [self.webView stringByEvaluatingJavaScriptFromString: loadUsernameJS];
    [self.webView stringByEvaluatingJavaScriptFromString: loadPasswordJS];
    [self.webView stringByEvaluatingJavaScriptFromString:@"console.log('MAGIC'+document.getElementsByTagName('html'[0].innerHTML);"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"doPCASLogin(this);"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"var ev = document.createEvent('KeyboardEvent'); ev.initKeyboardEvent('keydown', true, true, window, false, false, false, false, 13, 0);document.body.dispatchEvent(ev);"];
    
     NSString *yourHTMLSourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    NSLog(yourHTMLSourceCodeString);
    
    //[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('btn-enter').submit();"];
    //[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('LoginForm').submit()"];
    NSLog(@"\nFine, %i", counter);
    
    counter++;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
