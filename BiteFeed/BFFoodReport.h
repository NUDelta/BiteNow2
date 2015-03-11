//
//  BFFoodReport.h
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface BFFoodReport : NSObject

@property (strong, nonatomic) NSNumber *uniqueId;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lng;
@property (strong, nonatomic) NSString *floorNumber;
@property (strong, nonatomic) NSString *foodDrink;
@property (strong, nonatomic) NSString *foodType;
@property (strong, nonatomic) NSString *drinkType;
@property (strong, nonatomic) NSString *freeForAnyone;
@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSDate *createdAt;

+(instancetype)foodReportWithDictionary:(NSDictionary *)dictionary;
-(void)postReport;

@end
