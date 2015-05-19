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
@property (strong, nonatomic) NSArray *results;
- (IBAction)closeButton:(id)sender;


@end

@implementation SendingResultsViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSArray*) results
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        self.results = results;
    }
    
    return self;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleTableItem"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SimpleTableItem"];
    }
    
    NSString *text = [self.results objectAtIndex:indexPath.row];
    
    cell.textLabel.text = text;
    
    text = [text lowercaseString];
    
    if([text containsString:@"success"]) {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else if([text containsString:@"failure"] || [text containsString:@"error"] || [text containsString:@"bad"]){
        cell.textLabel.textColor = [UIColor redColor];
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.view.layer.cornerRadius = 5;
    self.view.layer.shadowOpacity = 0.8;
    self.view.layer.shadowOffset = CGSizeMake(0.8f, 0.8f);
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Message Details"
                              message:[self.results objectAtIndex:indexPath.row]
                              delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil];
    [alertView show];
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

- (IBAction)closeButton:(id)sender {
    [self closeAnimate];
}
@end
