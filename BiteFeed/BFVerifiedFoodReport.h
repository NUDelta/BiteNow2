//
//  BFFoodReport.h
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFVerifiedFoodReport : NSObject

@property (strong, nonatomic) NSNumber *uniqueId;
@property (strong, nonatomic) NSString *foodName;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lon;
@property (strong, nonatomic) NSString *detailLocation;
@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSDate *lastVerification;
@property (strong, nonatomic) NSString *amountRemaining;

@end
