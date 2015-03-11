//
//  BFFoodReport.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "BFFoodReport.h"

@implementation BFFoodReport

+(instancetype)foodReportWithDictionary:(NSDictionary *)dictionary
{
    BFFoodReport *report = [[BFFoodReport alloc] init];
    report.lat = [NSDecimalNumber decimalNumberWithString:[dictionary objectForKey:@"lat"]];
    report.lng = [NSDecimalNumber decimalNumberWithString:[dictionary objectForKey:@"lng"]];
    report.uniqueId = [dictionary objectForKey:@"id"];
    report.floorNumber = [dictionary objectForKey:@"floor_number"];
    report.foodDrink = [dictionary objectForKey:@"food_drink"];
    report.foodType = [dictionary objectForKey:@"food_type"];
    report.drinkType = [dictionary objectForKey:@"drink_type"];
    report.freeForAnyone = [dictionary objectForKey:@"free_for_anyone"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    report.updatedAt = [formatter dateFromString:[dictionary objectForKey:@"updated_at"]];
    report.createdAt = [formatter dateFromString:[dictionary objectForKey:@"created_at"]];
    return report;
}

-(BOOL) isEqual:(id)object {
    CLLocation *reportLocation = [[CLLocation alloc] initWithLatitude:self.lat.doubleValue longitude:self.lng.doubleValue];
    CLLocation *comparisonLocation = [[CLLocation alloc] initWithLatitude:[[object lat] doubleValue] longitude:[[object lng] doubleValue]];
    // reports less than half a meter from each other can be considered the same
    if ([reportLocation distanceFromLocation:comparisonLocation] < 0.5) {
        return YES;
    } else {
        return NO;
    }
}

-(void)postReport
{
//    if (self.lat && self.lng) {
//        [[RKObjectManager sharedManager] postObject:self path:@"http://gazetapshare.herokuapp.com/api/v1/tasks/new" parameters:@{@"lat":self.lat, @"lng":self.lon, @"question":@"hi"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//            NSLog(@"posted success!");
//            NSLog(mappingResult.description);
//        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            NSLog(@"error");
//            NSLog(error.description);
//        }];
//    }
}

@end
