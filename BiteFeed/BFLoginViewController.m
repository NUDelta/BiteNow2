//
//  BFLoginViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 2/4/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFLoginViewController.h"
#import <RestKit/RestKit.h>
#import "BFRestKitManager.h"
#import "BFUser.h"

@interface BFLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation BFLoginViewController

- (IBAction)startButtonPressed:(id)sender {
    if (self.usernameTextField.text.length <= 0){
        UIAlertView *noUsernameAlert = [[UIAlertView alloc] initWithTitle:@"no username" message:@"please enter a username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noUsernameAlert show];
    }
    if (self.emailTextField.text.length <= 0) {
        UIAlertView *noEmailAlert = [[UIAlertView alloc] initWithTitle:@"no email" message:@"please enter an email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noEmailAlert show];
    }
    if (self.emailTextField.text.length > 0 && self.usernameTextField.text.length > 0) {
        NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/users/new?user[username]=%@&&user[email]=%@", self.usernameTextField.text, self.emailTextField.text];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSError *JSONError = nil;
                NSDictionary* userResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
                NSString *username = [userResponse objectForKey:@"username"];
                NSString *email = [userResponse objectForKey:@"email"];
                NSNumber *uniqueId = [userResponse objectForKey:@"id"];
                if (!JSONError && username.length > 0 && uniqueId) {
                    [self saveUser:userResponse];
                }
            }
        }];
       /* BFUser *user = [BFUser fetchUser];
        NSLog(@"user's id is %@", user.uniqueId);
        //NSString *usern = self.usernameTextField.text;
        [[RKObjectManager sharedManager] getObject:user path:@"users/new" parameters:@{@"user[username]": self.usernameTextField.text, @"user[email]": self.emailTextField.text} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"%@", mappingResult);
            NSLog(mappingResult.description);
            NSLog(operation.description);
            [self performSegueWithIdentifier:@"loggedIn" sender:self];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(operation.description);
            NSLog(error.description);
        }];*/
    }
}

-(void)saveUser:(NSDictionary *)userResponse
{
    BFRestKitManager *manager = [BFRestKitManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectContext;
    //NSManagedObject *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    BFUser *user = [BFUser fetchUser];
    [user setValue:[userResponse objectForKey:@"id"] forKey:@"uniqueId"];
    [user setValue:[userResponse objectForKey:@"username"] forKey:@"username"];
    [user setValue:[userResponse objectForKey:@"email"] forKey:@"email"];
    [user setValue:[userResponse objectForKey:@"food_notifications"] forKey:@"foodNotifications"];
    [user setValue:[userResponse objectForKey:@"verify_reports"] forKey:@"verifyReports"];
    [user setValue:[userResponse objectForKey:@"daily_reminders"] forKey:@"dailyReminders"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    } else {
        [self performSegueWithIdentifier:@"loggedIn" sender:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
