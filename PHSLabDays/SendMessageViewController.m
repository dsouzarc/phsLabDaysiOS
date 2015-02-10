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

@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;

@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

- (IBAction)toMeButton:(id)sender;
- (IBAction)defaultButton:(id)sender;
- (IBAction)sendTextButton:(id)sender;
- (IBAction)clearSavedButton:(id)sender;

@property (strong, nonatomic) UICKeyChainStore *keychain;
@property (strong, nonatomic) MBProgressHUD *HUD;

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

- (IBAction)toMeButton:(id)sender {
    self.toTextField.text = @"6099154930@vtext.com";
}

- (IBAction)defaultButton:(id)sender {
    self.toTextField.text = @"6099154930@vtext.com";
    self.fromTextField.text = @"6099154930";
    self.subjectTextField.text = @" ";
    self.messageTextField.text = @"Yo";
}

id buttonSender;
bool hasSent = false;

- (IBAction)sendTextButton:(id)sender {
    
    [sender setTitle:@"Sending..." forState:UIControlStateNormal];
    buttonSender = sender;
    
    if(self.keychain[@"username"] == nil || self.keychain[@"password"] == nil) {
        [self setupSendGrid];
    }
    else {
        [self sendMessage];
    }
}

- (void)sendMessage {
    [buttonSender setTitle:@"Sending." forState:UIControlStateNormal];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.labelText = @"Sending Message...";
    self.HUD.detailsLabelText = @"Connecting to server...";
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    [self.view addSubview:self.HUD];
    [self.HUD showWhileExecuting:@selector(showProgress) onTarget:self withObject:nil animated:YES];
    
    SendGrid *sendgrid = [SendGrid apiUser:self.keychain[@"username"] apiKey:self.keychain[@"password"]];
    SendGridEmail *email = [[SendGridEmail alloc] init];
    
    email.to = self.toTextField.text;
    email.from = self.fromTextField.text;
    email.subject = self.subjectTextField.text;
    email.text = self.messageTextField.text;
    
    [sendgrid sendWithWeb:email
             successBlock:^(id responseObject) {
                 NSLog(@"SUCCESS!");
                 [self.HUD show:NO];
                 [buttonSender setTitle:@"Send Message" forState:UIControlStateNormal];
                 hasSent = true;
             }
             failureBlock:^(NSError *error) {
                 NSString *failureString = [NSString stringWithFormat:@"Failure: %@", error.description];
                 NSLog(failureString);
                 [buttonSender setTitle:failureString forState:UIControlStateNormal];
             }
     ];
}

- (IBAction)clearSavedButton:(id)sender {
    self.keychain[@"username"] = nil;
    self.keychain[@"password"] = nil;
}

- (void)showProgress {
    float progress = 0.0;
    
    while (progress < 1.0 && !hasSent) {
        progress += 0.01;
        self.HUD.progress = progress;
        
        if(progress == 0.5) {
            self.HUD.detailsLabelText = @"Executing script...";
        }
        else if(progress == 0.85) {
            self.HUD.detailsLabelText = @"Message sending...";
        }
        
        usleep(50000);
    }
    
    self.HUD.labelText = @"Successfully sent!";
    self.HUD.detailsLabelText = @"Message sent!";
    
    hasSent = true;
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
    
    [self sendMessage];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
