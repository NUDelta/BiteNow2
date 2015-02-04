//
//  WMRestKitManager.h
//  WingMan
//
//  Created by Stephen Chan on 9/4/14.
//  Copyright (c) 2014 TukoApps. All rights reserved.
//
// Manages all RestKit configuration of the application

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "BFVerifiedFoodReport.h"
#import "BFFoodReport.h"

@interface BFRestKitManager : NSObject

+(BFRestKitManager *)sharedManager;
-(void)updateUserLocation;

@end
