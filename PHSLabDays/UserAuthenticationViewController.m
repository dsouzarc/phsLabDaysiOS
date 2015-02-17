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

@property (strong, atomic) NSMutableSet *people;

@end

@implementation UserAuthenticationViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Update the global array with the recipients
        [self updateRecipientsFromFile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Say mission success
        });
    });

    // Do any additional setup after loading the view from its nib.
    
}

- (void) updateRecipientsFromFile {
    
    self.people = [[NSMutableSet alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PHS Lab Days (Responses)" ofType:@"csv"];
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
        NSArray *science1LabDays = [self getLabDays:personDetails[6]];
        
        NSArray *science2LabDays = [self getLabDays:personDetails[7]];
        NSString *science2Name = nil;
        
        if(personDetails.count > 8) {
            science2Name = personDetails[8];
        }
        
        Science *firstScience = [[Science alloc] initEverything:science1Name labDays:science1LabDays];
        Science *secondScience = science2Name == nil ? nil : [[Science alloc] initEverything:science2Name labDays:science2LabDays];
        
        Person *person = [[Person alloc] initEverything:name phoneNumber:phoneNumber carrier:carrier notificationSchedule:notificationSchedule scienceOne:firstScience scienceTwo:secondScience];
        
        [self.people addObject:person];
    }
    
    NSLog(@"SIZE!!!: %lu", (unsigned long)self.people.count);
}

- (NSArray *) getLabDays:(NSString *) raw
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < raw.length; i++) {
        unichar ascii = [raw characterAtIndex:i];
        
        switch (ascii) {
            case 65:
                [array addObject:@(A)];
                break;
            case 66:
                [array addObject:@(B)];
                break;
            case 67:
                [array addObject:@(C)];
                break;
            case 68:
                 [array addObject:@(D)];
                 break;
            case 69:
                [array addObject:@(E)];
                break;
            case 70:
                [array addObject:@(F)];
                break;
            case 71:
                [array addObject:@(G)];
                break;
            default:
                break;
        }
    }
    
    return array;
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

- (enum Notification) parseNotification:(NSString *)string
{
    if([string containsString:@"Every"]) {
        return EVERYDAY;
    }
    return LABDAYS;
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
