//
//  Science.m
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Science.h"

@implementation Science

- (instancetype) initEverything:(NSString *)scienceName labDays:(NSArray *)labDays_
{
    self = [super init];
    
    if(self) {
        _scienceName = scienceName;
        _labDays = labDays_;
    }
    
    return self;
}

- (BOOL) isLabDay:(enum LetterDay)letterDay
{
    for(int i = 0; i < self.labDays.count; i++) {
        if(((enum LetterDay)self.labDays[i]) == letterDay) {
            return YES;
        }
    }
    
    return NO;
}

@end
