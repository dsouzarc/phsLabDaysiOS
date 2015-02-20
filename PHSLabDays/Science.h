//
//  Science.h
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Science : NSObject

@property (nonatomic, readonly, copy) NSString *scienceName;
@property (nonatomic, readonly, copy) NSString *labDays;

- (instancetype) initEverything:(NSString*)scienceName labDays:(NSString*)labDays_;

- (BOOL) isLabDay:(NSString*)letterDay;
- (NSString *)toString;

@end
