//
//  Person.h
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property enum Carrier *carrier;
@property enum Notification *notificationSchedule;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phoneNumber;

@property (nonatomic, copy) NSString *scienceOne;
@property (nonatomic, copy) NSArray *scienceOneLabDays;
@property (nonatomic, copy) NSString *scienceTwo;
@property (nonatomic, copy) NSArray *scienceTwoLabDays;

enum Notification {JUST_LAB_DAYS, EVERY_DAY};
enum Carrier {VERIZON, ATTT, SPRINT, TMOBILE};
enum Letter_Day {A, B, C, D, E, F, G};

@end
