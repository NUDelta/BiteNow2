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
        [reportList populateReportList];
    });
    return reportList;
}

-(void)populateReportList
{
    NSMutableArray *comparisonReports = [[NSMutableArray alloc] init];
    NSString *url = @"http://localhost:3000/api/v1/tasks/verified";
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *JSONError = nil;
            NSArray* verifiedReports = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
            for (NSDictionary *verifiedReport in verifiedReports) {
                [comparisonReports addObject:[BFFoodReport foodReportWithDictionary:verifiedReport]];
            }
            NSSet *reportSet = [NSSet setWithArray:self.reportList];
            if (![[reportSet setByAddingObjectsFromArray:comparisonReports] isEqualToSet:reportSet]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reportUpdate" object:self];
                self.reportList = comparisonReports;
            }
        }
    }];
}

@end
