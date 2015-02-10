//
//  SendMessageViewController.m
//  TextPhone
//
//  Created by Ryan D'souza on 2/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "SendMessageViewController.h"

#import <UICKeyChainStore/UICKeyChainStore.h>
#import <SendGrid/SendGrid.h>
#import <SendGrid/SendGridEmail.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface SendMessageViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UICKeyChainStore *keychain;

@end

@implementation SendMessageViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keychain = [[UICKeyChainStore alloc] initWithService:@"APILogin"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Send Message loaded");
}


- (void) setupSendGrid {
     UIAlertView * alert = [[UIAlertView alloc]
                            initWithTitle:@"Login Information"
                            message:@"Please enter your login information:"
                            delegate:self
                            cancelButtonTitle:@"Continue"
                            otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    UITextField *usernameTextField = [alert textFieldAtIndex:0];
    usernameTextField.keyboardType = UIKeyboardTypeDefault;
    usernameTextField.placeholder = @"Username";
    
    UITextField *passwordTextField = [alert textFieldAtIndex:1];
    passwordTextField.keyboardType = UIKeyboardTypeDefault;
    passwordTextField.placeholder = @"Password";
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    
    self.keychain[@"username"] = [alertView textFieldAtIndex:0].text;
    self.keychain[@"password"] = [alertView textFieldAtIndex:1].text;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
