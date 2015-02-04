//
//  BFFoodReport.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFFoodReport.h"

@implementation BFFoodReport

+(instancetype)foodReportWithLat:(NSNumber *)lat Lon:(NSNumber *)lon;
{
    BFFoodReport *report = [[BFFoodReport alloc] init];
    report.lat = lat;
    report.lon = lon;
    return report;
}

-(void)postReport
{
    if (self.lat && self.lon) {
        [[RKObjectManager sharedManager] postObject:self path:@"http://gazetapshare.herokuapp.com/api/v1/tasks/new" parameters:@{@"lat":self.lat, @"lng":self.lon, @"question":@"hi"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"posted success!");
            NSLog(mappingResult.description);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"error");
            NSLog(error.description);
        }];
    }
}

@end
