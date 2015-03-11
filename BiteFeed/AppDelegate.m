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
    [self setRootViewController];
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
    UIMutableUserNotificationCategory* categoryFirstReport =[[UIMutableUserNotificationCategory alloc] init];
    categoryFirstReport.identifier = @"CancelReport";
    UIMutableUserNotificationAction* actionCancel = [[UIMutableUserNotificationAction alloc] init];
    actionCancel.title = @"Cancel Report";
    actionCancel.identifier = @"actionCancel";
    actionCancel.destructive = YES;
    actionCancel.authenticationRequired = NO;
    actionCancel.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionCancelArray = @[actionCancel];
    [categoryFirstReport setActions:actionCancelArray forContext:UIUserNotificationActionContextDefault];
    
    UIMutableUserNotificationCategory* categoryYesNo =[[UIMutableUserNotificationCategory alloc] init];
    categoryYesNo.identifier = @"1";
    UIMutableUserNotificationAction* actionYes = [[UIMutableUserNotificationAction alloc] init];
    actionYes.title = @"Yes";
    actionYes.identifier = @"actiontrue";
    actionYes.destructive = NO;
    actionYes.authenticationRequired = NO;
    actionYes.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* actionNo = [[UIMutableUserNotificationAction alloc] init];
    actionNo.title = @"No";
    actionNo.identifier = @"actionfalse";
    actionNo.authenticationRequired = NO;
    actionNo.destructive = YES;
    actionNo.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionYesNoArray = @[actionYes, actionNo];
    [categoryYesNo setActions:actionYesNoArray forContext:UIUserNotificationActionContextDefault];
    
    UIMutableUserNotificationCategory* categoryTechFord =[[UIMutableUserNotificationCategory alloc] init];
    categoryTechFord.identifier = @"2";
    UIMutableUserNotificationAction* actionTech = [[UIMutableUserNotificationAction alloc] init];
    actionTech.title = @"Tech";
    actionTech.identifier = @"actionTech";
    actionTech.destructive = NO;
    actionTech.authenticationRequired = NO;
    actionTech.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* actionFord = [[UIMutableUserNotificationAction alloc] init];
    actionFord.title = @"Ford";
    actionFord.identifier = @"actionFord";
    actionFord.authenticationRequired = NO;
    actionFord.destructive = NO;
    actionFord.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionTechFordArray = @[actionTech, actionFord];
    [categoryTechFord setActions:actionTechFordArray forContext:UIUserNotificationActionContextMinimal];
    
    UIMutableUserNotificationCategory* categoryFloors =[[UIMutableUserNotificationCategory alloc] init];
    categoryFloors.identifier = @"3";
    UIMutableUserNotificationAction* actionFirst = [[UIMutableUserNotificationAction alloc] init];
    actionFirst.title = @"1";
    actionFirst.identifier = @"action1";
    actionFirst.destructive = NO;
    actionFirst.authenticationRequired = NO;
    actionFirst.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* actionSecond = [[UIMutableUserNotificationAction alloc] init];
    actionSecond.title = @"2";
    actionSecond.identifier = @"action2";
    actionSecond.authenticationRequired = NO;
    actionSecond.destructive = NO;
    actionSecond.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionFirstFordArray = @[actionFirst, actionSecond];
    [categoryFloors setActions:actionFirstFordArray forContext:UIUserNotificationActionContextMinimal];
    
    UIMutableUserNotificationCategory* categoryFoodDrink =[[UIMutableUserNotificationCategory alloc] init];
    categoryFoodDrink.identifier = @"4";
    UIMutableUserNotificationAction* actionFood = [[UIMutableUserNotificationAction alloc] init];
    actionFood.title = @"food";
    actionFood.identifier = @"actionfood";
    actionFood.destructive = NO;
    actionFood.authenticationRequired = NO;
    actionFood.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* actionDrink = [[UIMutableUserNotificationAction alloc] init];
    actionDrink.title = @"drink";
    actionDrink.identifier = @"actiondrink";
    actionDrink.authenticationRequired = NO;
    actionDrink.destructive = NO;
    actionDrink.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionFoodFordArray = @[actionFood, actionDrink];
    [categoryFoodDrink setActions:actionFoodFordArray forContext:UIUserNotificationActionContextMinimal];
    
    UIMutableUserNotificationCategory *categoryPizzaDonuts = [[UIMutableUserNotificationCategory alloc] init];
    
    NSArray* actionCategories = @[categoryYesNo, categoryTechFord, categoryFloors, categoryFirstReport, categoryFoodDrink];
    NSSet *actionSet = [NSSet setWithArray:actionCategories];

    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:actionSet]];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *) application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *) notification completionHandler: (void (^)()) completionHandler {
    if ([notification.category isEqualToString:@"1"]) {
        [self confirmReport:notification withIdentifier:identifier];
    } else if ([notification.category isEqualToString:@"CancelReport"]) {
        [self cancelReportWithNotification:notification];
    } else {
        [self addAnswer:notification withIdentifier:identifier];
    }
    completionHandler();
}

-(void)cancelReportWithNotification:(UILocalNotification *)notification
{
    NSNumber *taskId = [notification.userInfo objectForKey:@"task_id"];
    NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/tasks/cancel?task_id=%@&&user_id=%@", taskId, [BFUser fetchUser].uniqueId];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", responseDictionary);
        }
    }];
}

-(void)confirmReport:(UILocalNotification *)notification withIdentifier:(NSString *)identifier
{
    NSNumber *questionId = [notification.userInfo valueForKey:@"question_id"];
    NSString *urlRequestString;
    if ([identifier isEqualToString:@"actionYes"]) {
        urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/answers/new?answer[question_id]=%d&answer[user_id]=%d&answer[value]=%@", questionId.intValue, [BFUser fetchUser].uniqueId.intValue, @"true"];
    } else {
        urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/answers/new?answer[question_id]=%d&answer[user_id]=%d&answer[value]=%@", questionId.intValue, [BFUser fetchUser].uniqueId.intValue, @"false"];
    }
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", responseDictionary);
        }
    }];
}

-(void)addAnswer:(UILocalNotification *)notification withIdentifier:(NSString *)identifier
{
    NSNumber *questionId = [notification.userInfo valueForKey:@"question_id"];
    NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/answers/new?answer[question_id]=%d&answer[user_id]=%d&answer[response]=%@", questionId.intValue, [BFUser fetchUser].uniqueId.intValue, [identifier stringByReplacingOccurrencesOfString:@"action" withString:@""]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
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
    /* hit zak's endpoint to create a new task */
    NSLog(@"current location: %f", self.locationManager.location.coordinate.latitude);
    NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/tasks/new?task[lat]=%f&task[lng]=%f&task[user_id]=%ld", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, (long)[BFUser fetchUser].uniqueId.integerValue];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRequestString]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            /* let the user know that they reported food */
            NSLog(@"successfully posted task");
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
            UILocalNotification *reportCreatedNotification = [[UILocalNotification alloc] init];
            reportCreatedNotification.alertBody = @"Thanks for reporting free food!";
            reportCreatedNotification.category = @"CancelReport";
            reportCreatedNotification.hasAction = NO;
            reportCreatedNotification.soundName = UILocalNotificationDefaultSoundName;
            reportCreatedNotification.userInfo = @{@"task_id": [responseDictionary objectForKey:@"id"]};
            [[UIApplication sharedApplication] presentLocalNotificationNow:reportCreatedNotification];
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
                        //if (![[eventResponse objectForKey:@"user_id"] isEqualToNumber:[BFUser fetchUser].uniqueId] && [eventResponse objectForKey:@"user_id"]) {
                            NSLog(@"%@", eventId);
                            [self.eventIdArray addObject:eventId];
                            UILocalNotification *eventNotification = [[UILocalNotification alloc] init];
                            eventNotification.alertBody = [eventResponse objectForKey:@"question_text"];
                            eventNotification.hasAction = YES;
                            eventNotification.alertAction = @"report no food exists";
                            eventNotification.soundName = UILocalNotificationDefaultSoundName;
                            if ([[eventResponse objectForKey:@"sequence_num"] compare:@5] == NSOrderedAscending) {
                                eventNotification.category = [NSString stringWithFormat:@"%@", [eventResponse objectForKey:@"sequence_num"]];
                            } else {
                                eventNotification.category = @"YesNo";
                            }
                            eventNotification.userInfo = @{@"question_id" : [eventResponse objectForKey:@"id"]};
                            [[UIApplication sharedApplication] presentLocalNotificationNow:eventNotification];
                        //}
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
        foodNotification.alertBody = [NSString stringWithFormat:@"Food was reported %@ meters away", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[foodLocation distanceFromLocation:currentLocation]]]];
        [[UIApplication sharedApplication] presentLocalNotificationNow:foodNotification];
    }
}

-(void)presentAlertViewFromVisibleController
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Is there food nearby?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Maybe", @"Yes", nil];
    [alertView show];
}

@end
