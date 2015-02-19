//
//  ViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFFeedViewController.h"
#import "BFFoodReport.h"

@interface BFFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) NSMutableArray *foodReports;

@end

@implementation BFFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.foodReports = [[NSMutableArray alloc] init];
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
    NSString *url = @"http://localhost:3000/api/v1/tasks/verified";
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *JSONError = nil;
            NSArray* verifiedReports = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
            for (NSDictionary *verifiedReport in verifiedReports) {
                [self.foodReports addObject:[BFFoodReport foodReportWithDictionary:verifiedReport]];
            }
            [self.feedTableView reloadData];
        }
    }];
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
    BFFoodReport *report = [self.foodReports objectAtIndex:indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
    [cell.textLabel setText:[NSString stringWithFormat:@"lat: %@, lng: %@", report.lat, report.lng]];
//    [cell.detailTextLabel setText:@"Distance"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foodReports.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //TODO: remove dummy data
    return 1;
}

@end
