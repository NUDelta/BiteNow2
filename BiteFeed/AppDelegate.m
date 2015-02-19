//
//  AppDelegate.m
//  BiteFeed
//
//  Created by Stephen Chan on 1/28/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "AppDelegate.h"
#import "BFRestKitManager.h"
#import "BFUser.h"
#import "BFQuestion.h"

@interface AppDelegate ()

@property (strong, nonatomic) TSTapDetector *tapDetector;
@property (strong, nonatomic) NSMutableArray *eventIdArray;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setRootViewController];
    //[self presentAlertViewFromVisibleController];
    [self beginLocationTracking];
    [self initTapDetection];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)] ) {
        UIMutableUserNotificationCategory* actionCategory =[[UIMutableUserNotificationCategory alloc] init];
        actionCategory.identifier = @"YesMaybeNo";
        UIMutableUserNotificationAction* actionYes = [[UIMutableUserNotificationAction alloc] init];
        actionYes.title = @"Yes";
        actionYes.identifier = @"actionYes";
        actionYes.authenticationRequired = NO;
        actionYes.activationMode = UIUserNotificationActivationModeBackground;
        UIMutableUserNotificationAction* actionNo = [[UIMutableUserNotificationAction alloc] init];
        actionNo.title = @"No";
        actionNo.identifier = @"actionNo";
        actionNo.authenticationRequired = NO;
        actionNo.activationMode = UIUserNotificationActivationModeBackground;
        NSArray* userNotificationActions = @[actionYes, actionNo];
        [actionCategory setActions:userNotificationActions forContext:UIUserNotificationActionContextDefault];
        NSArray* actionCategories = @[actionCategory];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:actionCategories]];
    } else {
        [application registerForRemoteNotifications];
    }
    self.eventIdArray = [[NSMutableArray alloc] init];
    return YES;
}

-(void)setRootViewController
{
    BFRestKitManager *manager = [BFRestKitManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectContext;
    if (context) {
        BFUser *user;
        @try {
            user = [BFUser fetchUser];
        } @catch (NSException *multiUserException) {
            if ([multiUserException.name isEqualToString:@"MultipleUserException"]) {
                NSLog(@"Resolving to arbitrary first user login record");
            }
        }
        if (user.username.length == 0) {
            UIViewController *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"login"];
            self.window.rootViewController = login;
        } else {
            NSLog(@"%@", user.email);
            UIViewController *home = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"home"];
            self.window.rootViewController = home;
        }
    }
}

-(void)beginLocationTracking
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}

-(void)initTapDetection
{
    self.tapDetector = [[TSTapDetector alloc] init];
    [self.tapDetector.listener collectMotionInformationWithInterval:10];
    self.tapDetector.delegate = self;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)detectorDidDetectTap:(TSTapDetector *)detector
{
    /* hit zak's endpoint to create a new task */
    NSLog(@"current location: %f", self.locationManager.location.coordinate.latitude);
//    [[BFFoodReport foodReportWithLat:[NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude] Lon:[NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude]] postReport];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    BFQuestion *question = [[BFQuestion alloc] init];
    CLLocation *location = [locations lastObject];
    if ([BFUser fetchUser].username.length > 0) {
//        NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/events/new?event[lat]=%f&event[lng]=%f&username=%@", location.coordinate.latitude, location.coordinate.longitude, [BFUser fetchUser].username];
        NSString *urlRequestString = [NSString stringWithFormat:@"http://localhost:3000/api/v1/events/new?event[lat]=%f&event[lng]=%f&username=%@", location.coordinate.latitude, location.coordinate.longitude, [BFUser fetchUser].username];
        
        NSLog(urlRequestString);
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSError *JSONError = nil;
                NSDictionary* eventResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
                
                if (eventResponse) {
                    NSNumber *eventId = [eventResponse objectForKey:@"id"];
                    if (![self.eventIdArray containsObject:eventId]) {
                        NSLog(@"%@", eventId);
                        [self.eventIdArray addObject:eventId];
                        UILocalNotification *eventNotification = [[UILocalNotification alloc] init];
                        eventNotification.alertBody = [eventResponse objectForKey:@"question_text"];
                        eventNotification.hasAction = YES;
                        eventNotification.category = @"YesMaybeNo";
                        //                    eventNotification.soundName = UILocalNotificationDefaultSoundName;
                        [[UIApplication sharedApplication] presentLocalNotificationNow:eventNotification];
                    } else {
                        NSLog(@"object found");
                    }
                }
            }
        }];
//        [[RKObjectManager sharedManager] getObject:question path:@"events/new" parameters:@{@"event[lat]":[NSNumber numberWithDouble:location.coordinate.latitude], @"event[lng]": [NSNumber numberWithDouble:location.coordinate.longitude], @"username":[[BFUser fetchUser] uniqueId]} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
////            NSLog(event);
//            NSLog(mappingResult.description);
//        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            NSLog(error.description);
//        }];
    }
}

-(void)presentAlertViewFromVisibleController
{
    //UIViewController *currentViewController = self.window.rootViewController;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Is there food nearby?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Maybe", @"Yes", nil];
    [alertView show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
