//
//  ViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFFeedViewController.h"
#import "BFFoodReportList.h"
#import "BFReportDetailViewController.h"

@interface BFFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) BFFoodReportList *foodReports;

@end

@implementation BFFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
}

-(void)initTableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"reportUpdate" object:nil];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    self.foodReports = [BFFoodReportList sharedFoodReportList];
    [self.foodReports populateReportList];
}

-(void)updateTableView
{
    [self.feedTableView reloadData];
}

-(void)initDataRequests
{
    // fill in next sprint with data request from Zak's endpoint
}

#pragma mark - table view delegate methods
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    [selectedCell setHighlighted:NO];
    [selectedCell setSelected:NO];
}

#pragma mark - table view data source methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BFFoodReport *report = [self.foodReports.reportList objectAtIndex:indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
    [cell.textLabel setText:[NSString stringWithFormat:@"lat: %@, lng: %@", report.lat, report.lng]];
//    [cell.detailTextLabel setText:@"Distance"];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reportDetail"]) {
        BFReportDetailViewController *detailController = (BFReportDetailViewController *)segue.destinationViewController;
        detailController.tableIndex = self.feedTableView.indexPathForSelectedRow.row;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foodReports.reportList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //TODO: remove dummy data
    return 1;
}

@end
