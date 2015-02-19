//
//  BFFoodReport.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFFoodReport.h"

@implementation BFFoodReport

+(instancetype)foodReportWithDictionary:(NSDictionary *)dictionary
{
    BFFoodReport *report = [[BFFoodReport alloc] init];
    report.lat = [dictionary objectForKey:@"lat"];
    report.lng = [dictionary objectForKey:@"lng"];
    return report;
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
