//
//  BFFoodReportList.m
//  BiteFeed
//
//  Created by Nicole Zhu on 2/19/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFFoodReportList.h"

@implementation BFFoodReportList

+(instancetype)sharedFoodReportList
{
    static BFFoodReportList *reportList = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        reportList = [[BFFoodReportList alloc] init];
        reportList.reportList = [[NSMutableArray alloc] init];
        [reportList populateReportList];
    });
    return reportList;
}

-(void)populateReportList
{
    NSString *url = @"http://gazetapshare.herokuapp.com/api/v1/tasks/verified";
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *JSONError = nil;
            NSArray* verifiedReports = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
            for (NSDictionary *verifiedReport in verifiedReports) {
                BFFoodReport *newReport = [BFFoodReport foodReportWithDictionary:verifiedReport];
                if (![self.reportList containsObject:newReport]) {
                    [self.reportList addObject:newReport];
                    // if the report was created in the last two minutes and not just due to
                    // closing the app, also send a notification
                    if ([[newReport.updatedAt dateByAddingTimeInterval:120] compare:[NSDate date]] == NSOrderedAscending) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reportUpdate" object:self userInfo:@{@"report":newReport}];
                    }
                }
            }
        }
    }];
}

@end
