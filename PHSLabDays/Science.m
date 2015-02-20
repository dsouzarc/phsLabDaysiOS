//
//  Science.m
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import "Science.h"

@implementation Science

- (instancetype) initEverything:(NSString *)scienceName labDays:(NSString *)labDays_
{
    self = [super init];
    
    if(self) {
        _scienceName = scienceName;
        _labDays = labDays_;
    }
    
    return self;
}

- (BOOL) isLabDay:(NSString*)letterDay
{
    return [self.labDays containsString:letterDay];
}

- (NSString*) toString
{
    return [NSString stringWithFormat:@"SCIENCE: %@\t LAB DAYS: %@", self.scienceName, self.labDays];
}

@end
