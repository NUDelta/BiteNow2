//
//  BFFoodReportList.h
//  BiteFeed
//
//  Created by Nicole Zhu on 2/19/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFFoodReport.h"

@interface BFFoodReportList : NSObject

+(instancetype)sharedFoodReportList;
@property (strong, nonatomic) NSMutableArray *reportList;
- (void) populateReportList;

@end
