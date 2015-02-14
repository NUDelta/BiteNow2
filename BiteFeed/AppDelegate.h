//
//  AppDelegate.h
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TSTapDetector.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, TSTapDetectorDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

-(void)detectorDidDetectTap:(TSTapDetector *)detector;

@end
