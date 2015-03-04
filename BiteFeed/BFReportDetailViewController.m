//
//  BFReportDetailViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFReportDetailViewController.h"
#import "BFFoodReportList.h"

@interface BFReportDetailViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *reportMapView;
@property (weak, nonatomic) IBOutlet UILabel *locationDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountDetailLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *backNavigationBar;
@property (strong, nonatomic) BFFoodReportList *foodReports;

@end

@implementation BFReportDetailViewController

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"reportUpdate" object:nil];
    self.foodReports = [BFFoodReportList sharedFoodReportList];
    [self.foodReports populateReportList];
    self.reportMapView.delegate = self;
    [self loadReportAnnotation];
    // Do any additional setup after loading the view.
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
