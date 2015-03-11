//
//  BFReportDetailViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFReportDetailViewController.h"
#import "BFFoodReportList.h"
#import "AppDelegate.h"

@interface BFReportDetailViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *reportMapView;
@property (weak, nonatomic) IBOutlet UILabel *locationDetailLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *backNavigationBar;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodTypeLabel;
@property (strong, nonatomic) BFFoodReportList *foodReports;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *notFreeForAllLabel;

@end

@implementation BFReportDetailViewController

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.foodReports = [BFFoodReportList sharedFoodReportList];
    [self.foodReports populateReportList];
    self.reportMapView.delegate = self;
    [self loadReportAnnotation];
    if (self.tableIndex >= 0) {
        [self addDetails];
    }
}

-(void)addDetails
{
    BFFoodReport *report = [[BFFoodReportList sharedFoodReportList].reportList objectAtIndex:self.tableIndex];
    self.floorLabel.text = [NSString stringWithFormat:@"Floor %@ of Ford", report.floorNumber];
    if ([report.foodDrink isEqualToString:@"food"]) {
        self.foodTypeLabel.text = report.foodType;
    } else {
        self.foodTypeLabel.text = report.drinkType;
    }
    CLLocation *reportLocation = [[CLLocation alloc] initWithLatitude:report.lat.doubleValue longitude:report.lng.doubleValue];
    self.distanceLabel.text = [NSString stringWithFormat:@"%f meters away from you", [reportLocation distanceFromLocation:((AppDelegate*)[UIApplication sharedApplication].delegate).locationManager.location]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.reportTimeLabel.text = [NSString stringWithFormat:@"reported at %@", [formatter stringFromDate:report.updatedAt]];
    // WARNING: this should really be uncommented. However, the logic for determining whether the
    // food is free for everyone seems to be a bit screwed up. For the sake of our study, we will
    // leave this commented out.
    //if ([report.freeForAnyone isEqualToString:@"yes"]) {
        self.notFreeForAllLabel.hidden = YES;
    //}
}

- (void)loadReportAnnotation {
    BFFoodReport *report = [self.foodReports.reportList objectAtIndex:self.tableIndex];
    CLLocationCoordinate2D reportLocation = CLLocationCoordinate2DMake(report.lat.doubleValue, report.lng.doubleValue);
    [self.reportMapView setCenterCoordinate:reportLocation animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(reportLocation, 800, 800);
    [self.reportMapView setRegion:region];
    MKPointAnnotation *reportAnnotation = [[MKPointAnnotation alloc] init];
    reportAnnotation.coordinate = reportLocation;
    reportAnnotation.title = @"Free food!";
    [self.reportMapView addAnnotation:reportAnnotation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
