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
#import "BFFoodReportList.h"

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
        // iOS 8 case
        [self registerUserNotificationCategoriesForApplication:application];
    } else {
        // iOS 7 case
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    self.eventIdArray = [[NSMutableArray alloc] init];
    [BFFoodReportList sharedFoodReportList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFoodNotification) name:@"reportUpdate" object:nil];
    return YES;
}

-(void)registerUserNotificationCategoriesForApplication:(UIApplication *)application
{
    UIMutableUserNotificationCategory* categoryYesNo =[[UIMutableUserNotificationCategory alloc] init];
    categoryYesNo.identifier = @"YesNo";
    UIMutableUserNotificationAction* actionYes = [[UIMutableUserNotificationAction alloc] init];
    actionYes.title = @"Yes";
    actionYes.identifier = @"actionYes";
    actionYes.destructive = NO;
    actionYes.authenticationRequired = NO;
    actionYes.activationMode = UIUserNotificationActivationModeForeground;
    UIMutableUserNotificationAction* actionNo = [[UIMutableUserNotificationAction alloc] init];
    actionNo.title = @"No";
    actionNo.identifier = @"actionNo";
    actionNo.authenticationRequired = NO;
    actionNo.destructive = YES;
    actionNo.activationMode = UIUserNotificationActivationModeForeground;
    NSArray* actionYesNoArray = @[actionYes, actionNo];
    [categoryYesNo setActions:actionYesNoArray forContext:UIUserNotificationActionContextDefault];
    
    UIMutableUserNotificationCategory* categoryLotLittle =[[UIMutableUserNotificationCategory alloc] init];
    categoryYesNo.identifier = @"LotLittle";
    UIMutableUserNotificationAction* actionLot = [[UIMutableUserNotificationAction alloc] init];
    actionYes.title = @"Lots";
    actionYes.identifier = @"actionLot";
    actionYes.destructive = NO;
    actionYes.authenticationRequired = NO;
    actionYes.activationMode = UIUserNotificationActivationModeForeground;
    UIMutableUserNotificationAction* actionLittle = [[UIMutableUserNotificationAction alloc] init];
    actionNo.title = @"Little";
    actionNo.identifier = @"actionLittle";
    actionNo.authenticationRequired = NO;
    actionNo.destructive = YES;
    actionNo.activationMode = UIUserNotificationActivationModeForeground;
    NSArray* actionLotLittleArray = @[actionLot, actionLittle];
    [categoryLotLittle setActions:actionLotLittleArray forContext:UIUserNotificationActionContextDefault];
    NSArray* actionCategories = @[categoryYesNo, categoryLotLittle];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:[NSSet setWithArray:actionCategories]]];   
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *) application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *) notification completionHandler: (void (^)()) completionHandler {
    if ([identifier isEqualToString: @"actionYes"]) {
        [self sendYesToQuestion:notification];
    }
    completionHandler();
}

-(void)sendYesToQuestion:(UILocalNotification *)notification
{
    NSLog(@"%@", notification);
    
    NSNumber *questionId = [notification.userInfo valueForKey:@"question_id"];
    NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/answers/new?answer[question_id]=%d&answer[user_id]=%d&answer[value]=%@", questionId.intValue, [BFUser fetchUser].uniqueId.intValue, @"Yes"];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
            NSLog(@"%@", responseDictionary);
        }
    }];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"got device token: %@", deviceToken);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", error);
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
    /* let the user know that they reported food */
    UILocalNotification *reportCreatedNotification = [[UILocalNotification alloc] init];
    reportCreatedNotification.alertBody = @"Thanks for reporting free food!";
    reportCreatedNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:reportCreatedNotification];
    /* hit zak's endpoint to create a new task */
    NSLog(@"current location: %f", self.locationManager.location.coordinate.latitude);
    NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/tasks/new?task[lat]=%f&task[lng]=%f&task[user_id]=%ld", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, (long)[BFUser fetchUser].uniqueId.integerValue];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSLog(@"successfully posted task");
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
            NSLog(@"%@", responseDictionary);
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [[BFFoodReportList sharedFoodReportList] populateReportList];
    BFQuestion *question = [[BFQuestion alloc] init];
    CLLocation *location = [locations lastObject];
    if ([BFUser fetchUser].username.length > 0) {
        NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/events/new?event[lat]=%f&event[lng]=%f&username=%@", location.coordinate.latitude, location.coordinate.longitude, [BFUser fetchUser].username];
        
        NSLog(@"%@", urlRequestString);
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSError *JSONError = nil;
                NSDictionary* eventResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&JSONError];
                if (eventResponse) {
                    NSNumber *eventId = [eventResponse objectForKey:@"id"];
                    if (![self.eventIdArray containsObject:eventId]) {
                        if (![[eventResponse objectForKey:@"user_id"] isEqualToNumber:[BFUser fetchUser].uniqueId]) {
                            NSLog(@"%@", eventId);
                            [self.eventIdArray addObject:eventId];
                            UILocalNotification *eventNotification = [[UILocalNotification alloc] init];
                            eventNotification.alertBody = [eventResponse objectForKey:@"question_text"];
                            eventNotification.hasAction = YES;
                            eventNotification.category = @"YesNo";
                            eventNotification.userInfo = @{@"question_id" : [eventResponse objectForKey:@"id"]};
                            [[UIApplication sharedApplication] presentLocalNotificationNow:eventNotification];
                        }
                    } else {
                        NSLog(@"object found");
                    }
                }
            }
        }];
    }
}

- (void)displayFoodNotification
{
    BFUser *user = [BFUser fetchUser];
    if (user.foodNotifications.boolValue) {
        UILocalNotification *foodNotification = [[UILocalNotification alloc] init];
        CLLocation *currentLocation = self.locationManager.location;
        BFFoodReport *foodReport = [[[BFFoodReportList sharedFoodReportList] reportList] lastObject];
        CLLocation *foodLocation = [[CLLocation alloc] initWithLatitude:foodReport.lat.doubleValue longitude:foodReport.lng.doubleValue];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setLocale:[NSLocale currentLocale]];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:1];
        foodNotification.alertBody = [NSString stringWithFormat:@"Food was reported %@ miles away", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[foodLocation distanceFromLocation:currentLocation]]]];
        [[UIApplication sharedApplication] presentLocalNotificationNow:foodNotification];
    }
}

-(void)presentAlertViewFromVisibleController
{
    //UIViewController *currentViewController = self.window.rootViewController;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Is there food nearby?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Maybe", @"Yes", nil];
    [alertView show];
}

@end
