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

#import "Person.h"
#import "Science.h"
#import "SendingResultsViewController.h"
#import "PQFCirclesInTriangle.h"

@interface SendMessageViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

- (IBAction)sendDailyMessageButton:(id)sender;
- (IBAction)clearSavedButton:(id)sender;
- (IBAction)sendSpecialMessageButton:(id)sender;
- (IBAction)numberOfDaysLeftStepper:(id)sender;

@property (nonatomic, strong) UICKeyChainStore *keychain;

@property (weak, nonatomic) IBOutlet UITextField *greetingTextField;
@property (weak, nonatomic) IBOutlet UITextField *nextVacationTextField;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSchoolDaysLeftLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *letterDayPickerView;

@property (strong, nonatomic) NSArray *_letterDayPickerData;
@property (strong, nonatomic) NSUserDefaults *_storedPreferences;
@property (strong, atomic) NSMutableSet *people;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, atomic) NSArray *letterDays;

@property (strong, nonatomic) UIAlertView *enterLoginInfoAV;
@property (strong, nonatomic) UIAlertView *confirmationDailyAV;
@property (strong, nonatomic) UIAlertView *sendSpecialMessageAV;

@property (strong, nonatomic) PQFCirclesInTriangle *loadingCircles;
@property (strong, nonatomic) SendingResultsViewController *resultsViewController;

@end

@implementation SendMessageViewController

const static NSString *FILENAME = @"PHS Lab Days (Responses)";

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.keychain = [[UICKeyChainStore alloc] initWithService:@"APILogin"];
        self._storedPreferences = [NSUserDefaults standardUserDefaults];
        self.letterDays = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G"];
        
        self._letterDayPickerData = self.letterDays;
        self.letterDayPickerView.showsSelectionIndicator = YES;
        self.letterDayPickerView.dataSource = self;
        self.letterDayPickerView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLetterDayFromSaved];
    
    self.greetingTextField.text = [self getGreetingFromStoredPreferences];
    self.nextVacationTextField.text = [self getNextVacationFromStoredPreferences];
    self.numberOfSchoolDaysLeftLabel.text = [self getNumberOfDaysLeftFromStoredPreferences];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Update the global array with the recipients
        [self updateRecipientsFromFile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Say mission success
            [self makeToast:@"Finished getting saved people from file" :[UIColor greenColor] :[UIColor blackColor]];
        });
    });
}

- (void) updateRecipientsFromFile {
    
    self.people = [[NSMutableSet alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:FILENAME ofType:@"csv"];
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    if(!fileContents) {
        NSLog(@"ERROR READING FILE");
        return;
    }
    else {
        NSLog(@"Gucci");
    }
    
    NSArray *data = [fileContents componentsSeparatedByString:@"\n"];
    
    for(int i = 0; i < data.count; i++) {
        NSString *line = data[i];
        
        line = [line stringByReplacingOccurrencesOfString:@", " withString:@"|"];
        line = [line stringByReplacingOccurrencesOfString:@",," withString:@", ,"];
        
        NSArray *personDetails = [line componentsSeparatedByString:@","];
        
        NSString *name = personDetails[1];
        NSString *phoneNumber = [self formatPhoneNumber:personDetails[2]];
        enum Carrier carrier = [self assignCarrier:personDetails[3]];
        enum Notification notificationSchedule = [self parseNotification:personDetails[4]];
        
        NSString *science1Name = personDetails[5];
        NSString *science1LabDays = personDetails[6];
        NSString *science2LabDays = personDetails[7];
        NSString *science2Name = nil;
        
        if(personDetails.count > 8) {
            science2Name = personDetails[8];
        }
        
        Science *firstScience = [[Science alloc]
                                 initEverything:science1Name labDays:science1LabDays];
        Science *secondScience = science2Name == nil ?
        nil : [[Science alloc] initEverything:science2Name labDays:science2LabDays];
        
        Person *person = [[Person alloc] initEverything:name phoneNumber:phoneNumber carrier:carrier
                                   notificationSchedule:notificationSchedule scienceOne:firstScience scienceTwo:secondScience];
        [self.people addObject:person];
    }
}


/****************************/
//    SENDING MESSAGES
/****************************/

- (void) sendDailyMessage
{
    self.results = [[NSMutableArray alloc] init];
    
    //If today is a monday
    const bool isMonday = [self isMonday];
    NSString *greeting = self.greetingTextField.text;
    NSString *nextVacation = self.nextVacationTextField.text;
    NSString *daysLeft = self.numberOfSchoolDaysLeftLabel.text;
    NSString *letterDay = self.letterDays[[self.letterDayPickerView selectedRowInComponent:0]];
    
    [self makeToast:@"Sending..." :[UIColor blackColor] :[UIColor greenColor]];
    
    self.loadingCircles = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
    self.loadingCircles.label.text = @"Sending...";
    self.loadingCircles.loaderColor = [UIColor blackColor];
    self.loadingCircles.borderWidth = 5.0;
    self.loadingCircles.label.textColor = [UIColor blackColor];
    self.loadingCircles.maxDiam = 200.0;
    [self.loadingCircles show];
    
    //NSURLRequests are intentionally not asynchronous
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Go through all the people
        for(Person *person in self.people) {
            
            //If it is monday or a lab day
            if(isMonday || [person shouldGetMessage:letterDay]) {
                
                //Subject
                NSString *subject = [[NSString alloc] initWithFormat:@"%@%@%@%@", greeting, @" ", person.name, @"!"];
                
                //Message
                NSMutableString *message = [[NSMutableString alloc] init];
                
                //Today is a X day
                if([letterDay containsString:@"A"] || [letterDay containsString:@"E"] || [letterDay containsString:@"F"]) {
                    [message appendString:@"Today is an '"];
                }
                else {
                    [message appendString:@"Today is a '"];
                }
                [message appendString:letterDay];
                [message appendString:@"' day. "];
                
                //Lab day message
                if([person shouldGetMessage:letterDay]) {
                    [message appendString:[person labDayMessage:letterDay]];
                    [message appendString:@". "];
                }
                
                //Monday message
                if(isMonday) {
                    NSString *remaining = [NSString stringWithFormat:@"%ld", (long)(180 - [daysLeft intValue])];
                    
                    [message appendString:[[NSString alloc] initWithFormat:@"%@%@%@%@", @"Days of School Left: ", remaining, @". Next Break: ", nextVacation]];
                }
                
                [self sendMessage:person subject:subject text:message];
            }
        }
        
        //Show results now
        dispatch_async(dispatch_get_main_queue(), ^{
            [CRToastManager dismissNotification:NO];
            
            [self makeToast:@"Finished sending" :[UIColor greenColor] :[UIColor blackColor]];
            [CRToastManager dismissNotification:NO];
            [self.loadingCircles hide];
            
            self.resultsViewController = [[SendingResultsViewController alloc] initWithNibName:@"SendingResultsViewController" bundle:nil data:self.results];
            [self.resultsViewController showInView:self.view animated:YES];
        });
    });
}

- (void)sendSpecialMessage:(NSString*)subject message:(NSString*)message
{
    self.results = [[NSMutableArray alloc] init];
    
    [self makeToast:@"Sending..." :[UIColor blackColor] :[UIColor greenColor]];
    
    self.loadingCircles = [[PQFCirclesInTriangle alloc] initLoaderOnView:self.view];
    self.loadingCircles.label.text = @"Sending...";
    self.loadingCircles.loaderColor = [UIColor blackColor];
    self.loadingCircles.borderWidth = 5.0;
    self.loadingCircles.label.textColor = [UIColor blackColor];
    self.loadingCircles.maxDiam = 200.0;
    [self.loadingCircles show];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Go through all the people
        for(Person *person in self.people) {
            [self sendMessage:person subject:subject text:message];
        }
        
        //Show results
        dispatch_async(dispatch_get_main_queue(), ^{
            [CRToastManager dismissNotification:NO];
    
            [self makeToast:@"Finished sending" :[UIColor greenColor] :[UIColor blackColor]];
            [CRToastManager dismissNotification:NO];
            [self.loadingCircles hide];
            
            self.resultsViewController = [[SendingResultsViewController alloc] initWithNibName:@"SendingResultsViewController" bundle:nil data:self.results];
            [self.resultsViewController showInView:self.view animated:YES];
        });
    });
}


/*********************************************/
//    SEND MESSAGE WITHOUT USING SENDGRID API
/*********************************************/

- (void) sendMessage:(Person*)person subject:(NSString*)subject text:(NSString*)text
{
    //API for sending messages
    static NSString *sendGridAPIURL = @"https://api.sendgrid.com/api/mail.send.json";
    
    //All POST data
    NSMutableString *postData = [[NSMutableString alloc] init];
    [postData appendString:[NSString stringWithFormat:@"api_user=%@", self.keychain[@"username"]]];
    [postData appendString:[NSString stringWithFormat:@"&api_key=%@", self.keychain[@"password"]]];
    [postData appendString:[NSString stringWithFormat:@"&to=%@", person.emailPhone]];
    [postData appendString:[NSString stringWithFormat:@"&subject=%@", subject]];
    [postData appendString:[NSString stringWithFormat:@"&text=%@", text]];
    
    //If the person has Verizon, make it come from a different address
    if(person.carrier == VERIZON) {
        [postData appendString:[NSString stringWithFormat:@"&from=%@", @"PHSLabDays"]];
    }
    else {
        [postData appendString:[NSString stringWithFormat:@"&from=%@", @"dsouzarc@gmail.com"]];
    }
    
    //The actual request --> Intentionally not asynchronous
    NSMutableURLRequest *sendGridRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sendGridAPIURL]];
    [sendGridRequest setHTTPMethod:@"POST"];
    [sendGridRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [sendGridRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    //Send the Request
    NSData *responseData = [NSURLConnection sendSynchronousRequest:sendGridRequest returningResponse:&response error:&error];
    
    //Basically hold the entire message --> For logging purposes
    NSMutableString *total = [[NSMutableString alloc] init];
    
    //Success or error when sending?
    if(error) {
        NSLog(@"ERROR SENDING!");
        [total appendString:error.description];
    }
    else {
        NSDictionary* results = [NSJSONSerialization JSONObjectWithData:responseData
                                                                options:kNilOptions
                                                                  error:nil];
        [total appendString:results[@"message"]];
    }
    [total appendString:@": "];
    
    //Add the name
    [total appendString:person.name];
    [total appendString:@": "];
    
    //Message and person details
    [total appendString:text];
    [total appendString:@". Sent to: "];
    [total appendString:person.emailPhone];
    
    //Add it in our array
    [self.results addObject:total];
}


/****************************/
//    BUTTON LISTENERS
/****************************/

- (IBAction)sendSpecialMessageButton:(id)sender {
    [sender setTitle:@"Send Special Message" forState:UIControlStateNormal];
    
    if(self.keychain[@"username"] == nil || self.keychain[@"password"] == nil) {
        [self setupSendGrid];
    }
    else {
        
        self.sendSpecialMessageAV = [[UIAlertView alloc]
                                     initWithTitle:@"Special Message Details"
                                     message:@"Enter the special message details"
                                     delegate:self
                                     cancelButtonTitle:@"Cancel"
                                     otherButtonTitles: @"Send message", nil];
        
        self.sendSpecialMessageAV.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        
        UITextField *subjectTF = [self.sendSpecialMessageAV textFieldAtIndex:0];
        subjectTF.keyboardType = UIKeyboardTypeDefault;
        subjectTF.placeholder = @"Message Subject";
        
        [self.sendSpecialMessageAV textFieldAtIndex:1].secureTextEntry = NO;
        UITextField *messageTF = [self.sendSpecialMessageAV textFieldAtIndex:1];
        messageTF.keyboardType = UIKeyboardTypeDefault;
        messageTF.placeholder = @"Message Field";
        
        [self.sendSpecialMessageAV show];
    }
}

- (IBAction)sendDailyMessageButton:(id)sender {
    [sender setTitle:@"Send Message" forState:UIControlStateNormal];
    
    if(self.keychain[@"username"] == nil || self.keychain[@"password"] == nil) {
        [self setupSendGrid];
    }
    else {
        self.confirmationDailyAV = [[UIAlertView alloc]
                                    initWithTitle:@"Confirmation"
                                    message:@"Are you sure you want to send this message?"
                                    delegate:self
                                    //^(UIAlertView *alertView, NSInteger buttonIndex) {
                                    //   NSLog(@"CLICKED:");
                                    //}
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Send Message", nil];
        [self.confirmationDailyAV show];
    }
}

- (IBAction)numberOfDaysLeftStepper:(UIStepper*)stepper {
    int increase = (int)[stepper value];
    int previous = [[self getNumberOfDaysLeftFromStoredPreferences] intValue];
    self.numberOfSchoolDaysLeftLabel.text = [NSString stringWithFormat:@"%d", (increase + previous)];
}


/***********************************/
//  VARIOUS FORMATTING AND CHECKING
/***********************************/

- (bool) isMonday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [comps weekday];
    
    //Sunday = 1, Monday = 2
    return (weekday == 2);
}

- (enum Carrier) assignCarrier:(NSString *)carrier
{
    carrier = [carrier lowercaseString];
    
    if([carrier containsString:@"verizon"]) {
        return VERIZON;
    }
    if([carrier containsString:@"at"]) {
        return ATTT;
    }
    if([carrier containsString:@"t-mobile"]) {
        return TMOBILE;
    }
    if([carrier containsString:@"virgin"]) {
        return VIRGINMOBILE;
    }
    if([carrier containsString:@"cingular"]) {
        return CINGULAR;
    }
    if([carrier containsString:@"sprint"]) {
        return SPRINT;
    }
    if([carrier containsString:@"nextel"]) {
        return NEXTEL;
    }
    NSLog(@"ERROR PARSING CARRIER: %@", carrier);
    return VERIZON;
}

- (NSString *) formatPhoneNumber:(NSString *)raw
{
    raw = [raw stringByReplacingOccurrencesOfString:@" " withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"(" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@")" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //In case some idiot puts 911
    raw = [raw stringByReplacingOccurrencesOfString:@"911" withString:@""];
    return raw;
}

- (void) saveInformation
{
    //The letter day info is already saved
    [self setNumberOfDaysLeftToStoredPreferences:self.numberOfSchoolDaysLeftLabel.text];
    [self setGreetingToStoredPreferences:self.greetingTextField.text];
    [self setNextVacationToStoredPreferences:self.nextVacationTextField.text];
}

- (enum Notification) parseNotification:(NSString *)string
{
    if([string containsString:@"Every"]) {
        return EVERYDAY;
    }
    return LABDAYS;
}

- (void) setLetterDayFromSaved
{
    NSString *letterDay = [self getLetterDayFromStoredPreferences];
    
    unichar letter = [[letterDay uppercaseString] characterAtIndex:0];
    int arrayLocation = letter - 65;
    [self.letterDayPickerView selectRow:arrayLocation inComponent:0 animated:YES];
}

- (void) setupSendGrid {
    self.enterLoginInfoAV = [[UIAlertView alloc]
                             initWithTitle:@"Login Information"
                             message:@"Please enter your login information:"
                             delegate:self
                             cancelButtonTitle:@"Continue"
                             otherButtonTitles:nil];
    
    self.enterLoginInfoAV.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    UITextField *usernameTextField = [self.enterLoginInfoAV textFieldAtIndex:0];
    usernameTextField.keyboardType = UIKeyboardTypeDefault;
    usernameTextField.placeholder = @"Username";
    
    UITextField *passwordTextField = [self.enterLoginInfoAV textFieldAtIndex:1];
    passwordTextField.keyboardType = UIKeyboardTypeDefault;
    passwordTextField.placeholder = @"Password";
    
    [self.enterLoginInfoAV show];
}


/****************************/
//   PICKERVIEW DELEGATE
/****************************/

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

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setLetterDayToStoredPreferences:self._letterDayPickerData[row]];
}


/****************************/
//  VARIOUS METHODS
/****************************/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)clearSavedButton:(id)sender {
    self.keychain[@"username"] = nil;
    self.keychain[@"password"] = nil;
    [self makeToast:@"User information cleared" :[UIColor redColor] :[UIColor blackColor]];
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
                                    NSLog(@"Finished showing notification.");
                                }];
}


/****************************/
//   STORED PREFERENCES
/****************************/

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

- (void) setNextVacationToStoredPreferences: (NSString *)vacation
{
    [self._storedPreferences setValue:vacation forKey:@"vacation"];
}

- (NSString*) getNextVacationFromStoredPreferences
{
    return [self._storedPreferences stringForKey:@"vacation"];
}

- (void) setNumberOfDaysLeftToStoredPreferences: (NSString*)numDays
{
    [self._storedPreferences setValue:numDays forKey:@"numDays"];
}

- (NSString*) getNumberOfDaysLeftFromStoredPreferences
{
    NSString* daysLeft = [self._storedPreferences stringForKey:@"numDays"];
    
    if(daysLeft == nil) {
        return @"100";
    }
    return daysLeft;
}


/****************************/
//    ALERTVIEW DELEGATES
/****************************/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView == self.enterLoginInfoAV) {
        
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
    
    else if(alertView == self.sendSpecialMessageAV) {
        
        if(buttonIndex == 1) {
            NSString *subject = [alertView textFieldAtIndex:0].text;
            NSString *message = [alertView textFieldAtIndex:1].text;
            
            [self sendSpecialMessage:subject message:message];
        }
    }
    
    else if(alertView == self.confirmationDailyAV) {
        
        //Yes, send the message
        if(buttonIndex == 1) {
            [self saveInformation];
            [self sendDailyMessage];
        }
    }
}

@end