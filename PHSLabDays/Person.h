//
//  Person.h
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, readonly) enum Carrier *carrier;
@property (nonatomic, readonly) enum Notification *notificationSchedule;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *phoneNumber;



- (instancetype) initEverything:(NSString*)name_ phoneNumber:(NSString*)phoneNumber_
                    carrier:(enum Notification)carrier_ notificationSchedule:(enum Notification)notificationSchedule_
                    scienceOne:(NSString*)scienceOne_ scienceOneLabDays:(NSString*)scienceOneLabDays_
                    scienceTwo:(NSString*)scienceTwo_ scienceTwoLabDays:(NSString*)scienceTwoLabDays_;

//When the person should get notifications
enum Notification {JUST_LAB_DAYS, EVERY_DAY};

//The person's carrier
enum Carrier {VERIZON, ATTT, SPRINT, TMOBILE};

//The letter day
enum Letter_Day {A, B, C, D, E, F, G};

@end
