//
//  UserAuthenticationViewController.m
//  TextPhone
//
//  Created by Ryan D'souza on 2/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "UserAuthenticationViewController.h"
#import "SendMessageViewController.h"

@interface UserAuthenticationViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) UITextField *passwordField;

@end

@implementation UserAuthenticationViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.passwordField.delegate = self;
    
    [self setNotificationForTomorrow];
}

- (void) setNotificationForTomorrow
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:
                        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound
                                                        categories:nil]];
    }
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar] ;
    NSDate *now = [NSDate date];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
    [components setHour:06];
    [components setMinute:25];
    
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.fireDate = [calendar dateFromComponents:components];
    notification.repeatInterval = NSDayCalendarUnit;
    [notification setAlertBody:@"Wake up!"];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *total = [NSString stringWithFormat:@"%@%@", textField.text, string];
    if([total isEqualToString:@"7"]) {
        SendMessageViewController *sendMessageVC = [[SendMessageViewController alloc] initWithNibName:@"SendMessageViewController" bundle:[NSBundle mainBundle]];
        
        [self presentViewController:sendMessageVC animated:YES completion:nil];
    }
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

//Closes the keyboard when screen is touched any where else
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
