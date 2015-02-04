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

@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lon;

+(instancetype)foodReportWithLat:(NSNumber *)lat Lon:(NSNumber *)lon;
-(void)postReport;

@end
