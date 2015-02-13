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
#import <CRToast/CRToast.h>

@interface SendMessageViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UICKeyChainStore *keychain;

@property (weak, nonatomic) IBOutlet UITextField *greetingTextField;
@property (weak, nonatomic) IBOutlet UITextField *nextVacationTextField;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSchoolDaysLeftLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *letterDayPickerView;

- (IBAction)sendDailyMessageButton:(id)sender;
- (IBAction)clearSavedButton:(id)sender;
- (IBAction)sendSpecialMessageButton:(id)sender;
- (IBAction)numberOfDaysLeftStepper:(id)sender;

@property (strong, nonatomic) NSArray *_letterDayPickerData;
@property (strong, nonatomic) NSUserDefaults *_storedPreferences;

@property (strong, atomic) NSMutableArray *people;

@end

@implementation SendMessageViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keychain = [[UICKeyChainStore alloc] initWithService:@"APILogin"];
        self._letterDayPickerData = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
        self._storedPreferences = [NSUserDefaults standardUserDefaults];
        
        self.letterDayPickerView.showsSelectionIndicator = YES;
        self.letterDayPickerView.dataSource = self;
        self.letterDayPickerView.delegate = self;
        
        //Set the letter day from the preference
        [self setLetterDayFromSaved];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //Update the global array with the recipients
            [self updateRecipientsFromFile];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Say mission success
            });
        });
    }
    return self;
}

- (void) updateRecipientsFromFile
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PHS Lab Days (Responses)" ofType:@"csv"];
    
    if(filePath) {
        NSString *text = [NSString stringWithContentsOfFile:filePath];
        //NSLog(@"CONTENTS: %@", text);
        NSArray *values = [text componentsSeparatedByString:@","];
        
        NSLog(@"VALUES: %@", values);
        
    }
    
}
- (void) setLetterDayFromSaved
{
    NSString *letterDay = [self getLetterDayFromStoredPreferences];
    
    unichar letter = [[letterDay uppercaseString] characterAtIndex:0];
    int arrayLocation = letter - 65;
    [self.letterDayPickerView selectRow:arrayLocation inComponent:0 animated:YES];
    
    NSLog(@"LETTER: %i", letter);
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLetterDayFromSaved];
    NSLog(@"Send Message loaded");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    
    if([alertView textFieldAtIndex:0].text.length <= 5 || [alertView textFieldAtIndex:1].text.length <= 5) {
        [self makeToast:@"Username/Password too short" :[UIColor redColor] :[UIColor blackColor]];
        [self setupSendGrid];
    }
    else {
        self.keychain[@"username"] = [alertView textFieldAtIndex:0].text;
        self.keychain[@"password"] = [alertView textFieldAtIndex:1].text;
        [self makeToast:@"Successfully saved username and password" :[UIColor greenColor] :[UIColor blackColor]];
    };
}

- (IBAction)sendSpecialMessageButton:(id)sender {
    [sender setTitle:@"Sending..." forState:UIControlStateNormal];

    if(self.keychain[@"username"] == nil || self.keychain[@"password"] == nil) {
        [self setupSendGrid];
    }
    else {
        //TO DO
        //[self sendMessage];
    }

}

- (IBAction)sendDailyMessageButton:(id)sender {
    [sender setTitle:@"Sending..." forState:UIControlStateNormal];
    
    if(self.keychain[@"username"] == nil || self.keychain[@"password"] == nil) {
        [self setupSendGrid];
    }
    else {
        //TO DO
        //[self sendMessage];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"CHOSEN: %@", self._letterDayPickerData[row]);
    NSString *chosenLetterDay = self._letterDayPickerData[row];
    [self setLetterDayToStoredPreferences:chosenLetterDay];
    NSLog(@"STORED %@", [self getLetterDayFromStoredPreferences]);
}

- (IBAction)numberOfDaysLeftStepper:(id)sender {
    
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self._letterDayPickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self._letterDayPickerData[row];
}

- (void)makeToast:(NSString *)toastMessage: (UIColor *)backgroundColor: (UIColor *)textColor {
    NSDictionary *options = @{
                              kCRToastTextKey : toastMessage,
                              kCRToastBackgroundColorKey : backgroundColor,
                              kCRToastTextColorKey : textColor,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                              kCRToastStatusBarStyleKey : @(CRToastTypeNavigationBar),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}

- (NSString *) getLetterDayFromStoredPreferences
{
    NSString *storedLetterDay = [self._storedPreferences stringForKey:@"letter_day"];
    
    if(storedLetterDay == nil) {
        return @"A";
    }
    return storedLetterDay;
}

- (void) setLetterDayToStoredPreferences: (NSString *)letterDay
{
    [self._storedPreferences setValue:letterDay forKey:@"letter_day"];
}

- (NSString *) getGreetingFromStoredPreferences
{
    NSString *storedGreeting = [self._storedPreferences stringForKey:@"greeting"];
    
    if(storedGreeting == nil) {
        return @"Hi ";
    }
    return storedGreeting;
}

- (void) setGreetingToStoredPreferences: (NSString *)greeting
{
    [self._storedPreferences setValue:greeting forKey:@"greeting"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)clearSavedButton:(id)sender {
    self.keychain[@"username"] = nil;
    self.keychain[@"password"] = nil;
    [self makeToast:@"User information cleared" :[UIColor redColor] :[UIColor blackColor]];
}
@end
