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
                        carrier:(enum Carrier)carrier_
                        notificationSchedule:(enum Notification)notificationSchedule_
                        scienceOne:(Science *)scienceOne_ scienceTwo:(Science *)scienceTwo_
{
    self = [super init];
    
    if(self) {
        _name = name;
        _phoneNumber = phoneNumber_;
        _carrier = &carrier_;
        _notificationSchedule = notificationSchedule_;
        _scienceOne = scienceOne_;
        _scienceTwo = scienceTwo_;
    }
    
    return self;
}

- (BOOL) shouldGetMessage:(enum LetterDay)letterDay_ {
    if(self.notificationSchedule == EVERYDAY) {
        return YES;
    }
    
    if(self.scienceTwo == nil) {
        return [self.scienceOne isLabDay:letterDay_];
    }
    return [self.scienceOne isLabDay:letterDay_] || [self.scienceTwo isLabDay:letterDay_];
}

- (NSString *) labDayMessage:(enum LetterDay)letterDay_
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    if([self.scienceOne isLabDay:letterDay_]) {
        [result appendString: [[NSString alloc] initWithFormat:@"Today is a lab day for %@", self.scienceOne.scienceName]];
    }
    
    if(self.scienceTwo != nil && [self.scienceTwo isLabDay:letterDay_]) {
        [result appendString: [[NSString alloc] initWithFormat:@"Today is a lab day for %@", self.scienceTwo.scienceName]];
    }
    
    return result;
}

//VERIZON, ATTT, SPRINT, TMOBILE, VIRGINMOBILE, CINGULAR, NEXTEL
- (NSString *) getCarrierEmail
{
    switch(self.carrier) {
        case VERIZON:
            return @"@vtext.com";
        case ATTT:
            return @"@txt.att.net";
        case SPRINT:
            return @"@messaging.sprintpcs.com";
        case TMOBILE:
            return @"@tmomail.net";
        case VIRGINMOBILE:
            return @"@vmobl.com";
        case CINGULAR:
            return @"@vmobl.com";
        case NEXTEL:
            return @"@messaging.nextel.com";
        default:
            return @"@vtext.com";
    }
}

- (NSString*) phoneEmail
{
    return [NSString stringWithFormat:@"%@%@", self.getCarrierEmail, self.phoneNumber];
}

- (NSUInteger) hash
{
    return [self.phoneEmail hash];
}

- (BOOL) isEqual:(id)object
{
    return self.hash == ((Person *)object).hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if(copy) {
    }
    
    return copy;
}


@end
