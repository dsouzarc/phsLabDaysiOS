//
//  Person.m
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Person.h"
#import "Science.h"

@implementation Person


- (instancetype) initEverything:(NSString *)name phoneNumber:(NSString *)phoneNumber_
                        carrier:(enum Carrier)carrier_ letterDay:(enum LetterDay)letterDay_
                        notificationSchedule:(enum Notification)notificationSchedule_
                        scienceOne:(Science *)scienceOne_ scienceTwo:(Science *)scienceTwo_
{
    self = [super init];
    
    if(self) {
        _name = name;
        _phoneNumber = phoneNumber_;
        _carrier = &carrier_;
        _letterDay = &letterDay_;
        _notificationSchedule = notificationSchedule_;
        _scienceOne = scienceOne_;
        _scienceTwo = scienceTwo_;
    }
    
    return self;
}

- (BOOL) shouldGetMessage {
    if(self.notificationSchedule == EVERYDAY) {
        return YES;
    }
    
    return [self.scienceOne isLabDay:self.letterDay] || [self.scienceTwo isLabDay:self.letterDay];
}

- (NSString *) labDayMessage
{
    return nil;
}


@end
