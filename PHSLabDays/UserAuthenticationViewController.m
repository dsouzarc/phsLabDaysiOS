//
//  UserAuthenticationViewController.m
//  TextPhone
//
//  Created by Ryan D'souza on 2/8/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "UserAuthenticationViewController.h"
#import "SendMessageViewController.h"
#import "Person.h"
#import "Science.h"

@interface UserAuthenticationViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *rootView;

@property (nonatomic, strong) UITextField *passwordField;

@end

@implementation UserAuthenticationViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    
    NSArray *ab1 = [[NSArray alloc] initWithObjects:(enum LetterDay)A, (enum LetterDay)B, nil];
    NSArray *ab = [[NSArray alloc] initWithObjects:(enum LetterDay)A, (enum LetterDay)B, nil];
    //NSArray *bc = [[NSArray alloc] initWithObjects:(enum LetterDay)D, (enum LetterDay)D, nil];
    
    Science *first = [[Science alloc] initEverything:@"Temp1" labDays:ab];
    Science *second = [[Science alloc] initEverything:@"Temp2" labDays:ab1];
    
    Person *me = [[Person alloc] initEverything:@"Hello" phoneNumber:@"609" carrier:VERIZON letterDay:A notificationSchedule:EVERYDAY scienceOne:first scienceTwo:second];
    
    if([me shouldGetMessage]) {
        NSLog(@"YES!!");
    }
    else {
        NSLog(@"NOPE!!");
    }
    
    
    return self;
}

//Closes the keyboard when screen is touched any where else
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.passwordField.delegate = self;

    // Do any additional setup after loading the view from its nib.
    
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
