//
//  Person.h
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Science;

//When the person should get notifications
typedef NS_ENUM(NSUInteger, Notification) { EVERYDAY, LABDAYS};
typedef NS_ENUM(NSUInteger, Carrier) {VERIZON, ATTT, SPRINT, TMOBILE};
typedef NS_ENUM(NSUInteger, LetterDay) {A, B, C, D, E, F, G};

@interface Person : NSObject


@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *phoneNumber;

@property (nonatomic, readonly) enum Carrier *carrier;
@property (nonatomic, readonly) enum Notification notificationSchedule;
@property (nonatomic, readonly) enum LetterDay *letterDay;

@property (nonatomic, readonly, copy) Science *scienceOne;
@property (nonatomic, readonly, copy) Science *scienceTwo;

- (instancetype) initEverything:(NSString*)name phoneNumber:(NSString*)phoneNumber_
                        carrier:(enum Carrier)carrier_ letterDay:(enum LetterDay)letterDay_
                        notificationSchedule:(enum Notification)notificationSchedule_
                        scienceOne:(Science*)scienceOne_ scienceTwo:(Science*)scienceTwo_;

- (BOOL) shouldGetMessage;
- (NSString*) labDayMessage;

@end
