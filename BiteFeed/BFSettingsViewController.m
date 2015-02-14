//
//  BFSettingsViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 2/10/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFSettingsViewController.h"
#import "BFUser.h"

@interface BFSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *foodNotificationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *verifyReportsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dailyRemindersSwitch;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@end

@implementation BFSettingsViewController

-(void)viewDidLoad
{
    self.userLabel.text = [BFUser fetchUser].username;
}

- (IBAction)foodNotificationSwitchChanged:(id)sender {
    [[BFUser fetchUser] setFoodNotifications:[NSNumber numberWithBool:self.foodNotificationSwitch.isOn]];
    [BFUser updateSettings];
}

- (IBAction)verifyReportsSwitchChanged:(id)sender {
    [[BFUser fetchUser] setVerifyReports:[NSNumber numberWithBool:self.verifyReportsSwitch.isOn]];
    [BFUser updateSettings];
}

- (IBAction)dailyRemindersSwitchChanged:(id)sender {
    [[BFUser fetchUser] setDailyReminders:[NSNumber numberWithBool:self.dailyRemindersSwitch.isOn]];
    [BFUser updateSettings];
}


@end
