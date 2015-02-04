//
//  ViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFFeedViewController.h"

@interface BFFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) NSMutableArray *foodReports;

@end

@implementation BFFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
}

-(void)initTableView
{
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    [self loadFoodReports];
}

-(void)loadFoodReports
{
    /*NSDictionary *requestParams = @{@"verified" : YES, @"lat" : , @"lon" : };
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/api/v1/bars" parameters:requestParams success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
            self.barInfo = mappingResult.array;
            [self.spinner removeFromSuperview];
        
            // reset update timer
            [[WMRestKitManager sharedManager] updateUserLocation];
            // before loading, tableview's separators are removed since the cells resize
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            [self.tableView reloadData];
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error){
            NSLog(@"%@", error);
        }];*/
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
    [cell.textLabel setText:@"Name of food"];
    [cell.detailTextLabel setText:@"Distance"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: remove dummy data
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //TODO: remove dummy data
    return 1;
}

@end
