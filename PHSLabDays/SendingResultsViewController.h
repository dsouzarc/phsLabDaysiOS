//
//  SendingResultsViewController.h
//  PHSLabDays
//
//  Created by Ryan D'souza on 3/4/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendingResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil data:(NSArray*) results;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@end
