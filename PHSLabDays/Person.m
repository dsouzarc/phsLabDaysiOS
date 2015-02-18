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
    
    NSLog(@"Called");
    
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

+ (NSString*) letterDayToString:(enum LetterDay)day_
{
    switch (day_) {
        case A:
            return @"A";
        case B:
            return @"B";
        case C:
            return @"C";
        case D:
            return @"D";
        case E:
            return @"E";
        case F:
            return @"F";
        case G:
            return @"G";
        default:
            NSLog(@"INVALID AT TOSTRING ");
            return @"INVALID";
    }
}

- (enum LetterDay) letterDayFromString: (NSString*)string_
{
    return [self asciiToLetterDay:[string_ characterAtIndex:0]];
}

- (enum LetterDay) asciiToLetterDay:(unichar)ascii
{
    switch (ascii) {
        case 65:
            return A;
            break;
        case 66:
            return B;
        case 67:
            return C;
        case 68:
            return D;
            break;
        case 69:
            return E;
        case 70:
            return F;
        case 71:
            return G;
        default:
            return nil;
    }
}

- (NSString*) emailPhone
{
    return [NSString stringWithFormat:@"%@%@", self.phoneNumber, self.getCarrierEmail];
}

- (NSUInteger) hash
{
    return [self.emailPhone hash];
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

- (NSString*) notificationScheduleAsString
{
    if(self.notificationSchedule == EVERYDAY) {
        return @"Everyday";
    }
    return @"Just on Lab Days";
}

- (NSString*) toString
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result appendString:self.name];
    [result appendString:self.emailPhone];
    [result appendString:self.notificationScheduleAsString];
    [result appendString:self.scienceOne.toString];
    
    if(self.scienceTwo != nil) {
        [result appendString:self.scienceTwo.toString];
    }
    return result;
}

@end
