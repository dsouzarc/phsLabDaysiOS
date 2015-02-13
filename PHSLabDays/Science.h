//
//  Science.h
//  PHSLabDays
//
//  Created by Ryan D'souza on 2/12/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Science : NSObject

@property (nonatomic, readonly, copy) NSString *scienceName;
@property (nonatomic, readonly, copy) NSArray *labDays;

- (instancetype) initEverything:(NSString*)scienceName labDays:(NSArray*)labDays_;

@end
