//
//  BFUser.m
//  BiteFeed
//
//  Created by Stephen Chan on 2/4/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFUser.h"
#import "AppDelegate.h"
#import "BFRestKitManager.h"

@implementation BFUser

@dynamic uniqueId;
@dynamic username;
@dynamic email;
@dynamic foodNotifications;
@dynamic verifyReports;
@dynamic dailyReminders;

+(BFUser *)fetchUser
{
    BFRestKitManager *manager = [BFRestKitManager sharedManager];
    NSManagedObjectContext *context = [manager managedObjectContext];
    NSEntityDescription *userEntityDescription = [NSEntityDescription
                                                  entityForName:@"User" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:userEntityDescription];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array.count == 0) {
        BFUser *user = (BFUser *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        NSError *error;
        if ([context save:&error]) {
           return user;
        } else {
            return nil;
        }
    } else if ([array count] > 1) {
        NSException* multiUserException = [NSException
                                           exceptionWithName:@"MultipleUserException"
                                           reason:@"Ambiguous users - multiple users are logged in"
                                           userInfo:nil];
        @throw multiUserException;
    } else {
        [BFRestKitManager sharedManager];
        return [array firstObject];
    }
}

+(void)updateSettings
{
    NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/users/update?user[user_id]=%@&&user[food_notifications]=%@&&user[verify_reports]=%@&&user[daily_reminders]=%@", [BFUser fetchUser].uniqueId, [BFUser fetchUser].foodNotifications, [BFUser fetchUser].verifyReports, [BFUser fetchUser].dailyReminders];
    urlRequestString = [urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(urlRequestString);
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *JSONError = nil;
            NSDictionary* userResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
            NSString *username = [userResponse objectForKey:@"username"];
            NSNumber *uniqueId = [userResponse objectForKey:@"id"];
            if (!JSONError && username.length > 0 && uniqueId) {
                [BFUser updateUser:userResponse];
            }
        } else {
            NSLog(connectionError.description);
        }
    }];
}

+(void)updateUser:(NSDictionary *)userResponse
{
    BFUser *user = [BFUser fetchUser];
    [user setValue:[userResponse objectForKey:@"id"] forKey:@"uniqueId"];
    [user setValue:[userResponse objectForKey:@"username"] forKey:@"username"];
    [user setValue:[userResponse objectForKey:@"email"] forKey:@"email"];
    [user setValue:[userResponse objectForKey:@"food_notifications"] forKey:@"foodNotifications"];
    [user setValue:[userResponse objectForKey:@"verify_reports"] forKey:@"verifyReports"];
    [user setValue:[userResponse objectForKey:@"daily_reminders"] forKey:@"dailyReminders"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![[BFRestKitManager sharedManager].managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    } else {
    }
}

@end
