//
//  SendingResultsViewController.m
//  PHSLabDays
//
//  Created by Ryan D'souza on 3/4/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "SendingResultsViewController.h"
#import "Person.h"

@interface SendingResultsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary *resultsToDisplay;
@property (strong, nonatomic) NSArray *resultsKeyArray;

- (IBAction)closeWindowButton:(id)sender;

@end

@implementation SendingResultsViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSDictionary *)resultsToDisplay
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.resultsToDisplay = resultsToDisplay;
        self.resultsKeyArray = [resultsToDisplay allKeys];
    }
    
    return self;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultsKeyArray.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleTableItem"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimpleTableItem"];
    }
    
    NSString *referralKey = [self.resultsKeyArray objectAtIndex:indexPath.row];
    Person *person = [self.resultsToDisplay objectForKey:referralKey];
    
    NSMutableString *text = [[NSMutableString alloc] init];
    
    //Format: 'Success: ' or 'Failure: '
    [text appendString:referralKey];
    [text appendString:@": "];
    
    [text appendString:person.name];
    [text appendString:@" "];
    [text appendString:]
    
    
    return cell;
}


- (void)viewDidLoad {
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.view.layer.cornerRadius = 5;
    self.view.layer.shadowOpacity = 0.8;
    self.view.layer.shadowOffset = CGSizeMake(0.8f, 0.8f);
    [super viewDidLoad];
}

- (void) showAnimate
{
    self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.view.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void) closeAnimate
{
    [UIView animateWithDuration:.25 animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.view removeFromSuperview];
        }
    }];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self.view];
    if (animated) {
        [self showAnimate];
    }
}

- (IBAction)closeWindowButton:(id)sender {
    [self closeAnimate];
}

@end
