//
//  BFContributeViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFContributeViewController.h"
#import "BFFoodReport.h"

@interface BFContributeViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) TSTapDetector *tapDetector;

@end

@implementation BFContributeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLocationListener];
    [self initTapDetection];
    //[self tryRestKit];
}

-(void)tryRestKit
{
    [[BFFoodReport foodReportWithLat:@45.0234 Lon:@-87.2543242] postReport];
}

-(void)initLocationListener
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void){}];
}

-(void)initTapDetection
{
    self.tapDetector = [[TSTapDetector alloc] init];
    [self.tapDetector.listener collectMotionInformationWithInterval:10];
    self.tapDetector.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

-(void)detectorDidDetectTap:(TSTapDetector *)detector
{
    /* hit zak's endpoint to create a new task */
    NSLog(@"current location: %f", self.locationManager.location.coordinate.latitude);
    [[BFFoodReport foodReportWithLat:[NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude] Lon:[NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude]] postReport];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    /* hit zak's endpoint to see if there's anything to verify nearby */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
