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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFoodNotification:) name:@"reportUpdate" object:nil];
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
    
    UIMutableUserNotificationCategory* categoryFloors =[[UIMutableUserNotificationCategory alloc] init];
    categoryFloors.identifier = @"2";
    UIMutableUserNotificationAction* actionG = [[UIMutableUserNotificationAction alloc] init];
    actionG.title = @"G";
    actionG.identifier = @"actionG";
    actionG.destructive = NO;
    actionG.authenticationRequired = NO;
    actionG.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* action2 = [[UIMutableUserNotificationAction alloc] init];
    action2.title = @"2";
    action2.identifier = @"action2";
    action2.authenticationRequired = NO;
    action2.destructive = NO;
    action2.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionG2Array = @[actionG, action2];
    [categoryFloors setActions:actionG2Array forContext:UIUserNotificationActionContextMinimal];
    
    UIMutableUserNotificationCategory* categoryFoodDrink =[[UIMutableUserNotificationCategory alloc] init];
    categoryFoodDrink.identifier = @"3";
    UIMutableUserNotificationAction* actionFood = [[UIMutableUserNotificationAction alloc] init];
    actionFood.title = @"Food";
    actionFood.identifier = @"actionfood";
    actionFood.destructive = NO;
    actionFood.authenticationRequired = NO;
    actionFood.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* actionDrink = [[UIMutableUserNotificationAction alloc] init];
    actionDrink.title = @"Drink";
    actionDrink.identifier = @"actiondrink";
    actionDrink.authenticationRequired = NO;
    actionDrink.destructive = NO;
    actionDrink.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionFoodDrinkArray = @[actionFood, actionDrink];
    [categoryFoodDrink setActions:actionFoodDrinkArray forContext:UIUserNotificationActionContextMinimal];
    
    UIMutableUserNotificationCategory* categoryFreeForAll =[[UIMutableUserNotificationCategory alloc] init];
    categoryFreeForAll.identifier = @"5";
    [categoryFreeForAll setActions:actionYesNoArray forContext:UIUserNotificationActionContextMinimal];
    
    // We're dynamically changing the choices of types of food
    // each day, but we only ask users to choose between two.
    // On the other hand, all interactive notification categories
    // have to be set ahead of time, so we register them all here
    // and decide which one to use when the notification is displayed.
    
    // Wednesday's food
    UIMutableUserNotificationCategory *categoryPizzaDonuts = [[UIMutableUserNotificationCategory alloc] init];
    categoryPizzaDonuts.identifier = @"WEDNESDAY";
    UIMutableUserNotificationAction *actionPizza = [[UIMutableUserNotificationAction alloc] init];
    actionPizza.title = @"Pizza";
    actionPizza.identifier = @"actionpizza";
    actionPizza.destructive = NO;
    actionPizza.authenticationRequired = NO;
    actionPizza.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction *actionDonuts = [[UIMutableUserNotificationAction alloc] init];
    actionDonuts.title = @"Donuts";
    actionDonuts.identifier = @"actiondonuts";
    actionDonuts.destructive = NO;
    actionDonuts.authenticationRequired = NO;
    actionDonuts.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionPizzaDonutsArray = @[actionPizza, actionDonuts];
    [categoryPizzaDonuts setActions:actionPizzaDonutsArray forContext:UIUserNotificationActionContextMinimal];
    
    //Answers (if food): [pizza, donuts, cookies, bagels, fruit/veggies],
    //Answers (if drink): [coffee, soda]

    // Thursday's drinks
    UIMutableUserNotificationCategory *categoryCoffeeSoda = [[UIMutableUserNotificationCategory alloc] init];
    categoryCoffeeSoda.identifier = @"THURSDAY_DRINK";
    UIMutableUserNotificationAction *actionCoffee = [[UIMutableUserNotificationAction alloc] init];
    actionCoffee.title = @"Coffee";
    actionCoffee.identifier = @"actioncoffee";
    actionCoffee.destructive = NO;
    actionCoffee.authenticationRequired = NO;
    actionCoffee.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction *actionSoda = [[UIMutableUserNotificationAction alloc] init];
    actionSoda.title = @"Soda";
    actionSoda.identifier = @"actionsoda";
    actionSoda.destructive = NO;
    actionSoda.authenticationRequired = NO;
    actionSoda.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionCoffeeSodaArray = @[actionCoffee, actionSoda];
    [categoryCoffeeSoda setActions:actionCoffeeSodaArray forContext:UIUserNotificationActionContextMinimal];
    
    // Thursday's food
    UIMutableUserNotificationCategory *categoryCookiesBagels = [[UIMutableUserNotificationCategory alloc] init];
    categoryCookiesBagels.identifier = @"THURSDAY_FOOD";
    UIMutableUserNotificationAction *actionCookies = [[UIMutableUserNotificationAction alloc] init];
    actionCookies.title = @"Cookies";
    actionCookies.identifier = @"actioncookies";
    actionCookies.destructive = NO;
    actionCookies.authenticationRequired = NO;
    actionCookies.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction *actionBagels = [[UIMutableUserNotificationAction alloc] init];
    actionBagels.title = @"Bagels";
    actionBagels.identifier = @"actionbagels";
    actionBagels.destructive = NO;
    actionBagels.authenticationRequired = NO;
    actionBagels.activationMode = UIUserNotificationActivationModeBackground;
    NSArray* actionCookiesBagelsArray = @[actionCookies, actionBagels];
    [categoryCookiesBagels setActions:actionCookiesBagelsArray forContext:UIUserNotificationActionContextMinimal];
    
    // Friday's food - AM
    UIMutableUserNotificationCategory *categoryOreosFruit = [[UIMutableUserNotificationCategory alloc] init];
    categoryOreosFruit.identifier = @"FRIDAY_FOOD_AM";
    UIMutableUserNotificationAction *actionOreos = [[UIMutableUserNotificationAction alloc] init];
    actionOreos.title = @"Oreos";
    actionOreos.identifier = @"actionoreos";
    actionOreos.destructive = NO;
    actionOreos.authenticationRequired = NO;
    actionOreos.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction *actionFruit = [[UIMutableUserNotificationAction alloc] init];
    actionFruit.title = @"Fruit";
    actionFruit.identifier = @"actionfruit";
    actionFruit.destructive = NO;
    actionFruit.authenticationRequired = NO;
    actionFruit.activationMode = UIUserNotificationActivationModeBackground;
    NSArray *actionOreosFruitArray = @[actionOreos, actionFruit];
    [categoryOreosFruit setActions:actionOreosFruitArray forContext:UIUserNotificationActionContextMinimal];
    
    // Friday's food - PM. Note we're just reusing a category from above, but making its usage
    // explicit here.
    UIMutableUserNotificationCategory *categoryPizzaDonuts2 = [[UIMutableUserNotificationCategory alloc] init];
    categoryPizzaDonuts2.identifier = @"FRIDAY_FOOD_PM";
    [categoryPizzaDonuts2 setActions:actionPizzaDonutsArray forContext:UIUserNotificationActionContextMinimal];
    
    // Friday's drink - PM. Note we're just reusing a category from above, but making its usage
    // explicit here.
    UIMutableUserNotificationCategory *categoryCoffeeSoda2 = [[UIMutableUserNotificationCategory alloc] init];
    categoryCoffeeSoda2.identifier = @"FRIDAY_DRINK_PM";
    [categoryCoffeeSoda2 setActions:actionCoffeeSodaArray forContext:UIUserNotificationActionContextMinimal];
    
    NSArray* actionCategories = @[categoryYesNo, categoryFloors, categoryFirstReport, categoryFoodDrink, categoryCoffeeSoda, categoryPizzaDonuts, categoryCookiesBagels, categoryOreosFruit, categoryPizzaDonuts2, categoryCoffeeSoda2, categoryFreeForAll];
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

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([application applicationState] == UIApplicationStateActive) {
        // present the notification as an alert view
    }
}

-(void)cancelReportWithNotification:(UILocalNotification *)notification
{
    NSNumber *taskId = [notification.userInfo objectForKey:@"task_id"];
    NSString *urlRequestString = [NSString stringWithFormat:@"http://gazetapshare.herokuapp.com/api/v1/tasks/cancel?task_id=%@&&user_id=%@", taskId, [BFUser fetchUser].uniqueId];
    urlRequestString = [urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    urlRequestString = [urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    urlRequestString = [urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    urlRequestString = [urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
        urlRequestString = [urlRequestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
                            eventNotification.soundName = UILocalNotificationDefaultSoundName;
                            // notice that the first 3 questions are static, but the food type
                            // questions are dynamically determined by us
                            if ([[eventResponse objectForKey:@"sequence_num"] compare:@4] == NSOrderedAscending || [[eventResponse objectForKey:@"sequence_num"] compare:@5] == NSOrderedSame) {
                                eventNotification.category = [NSString stringWithFormat:@"%@", [eventResponse objectForKey:@"sequence_num"]];
                            } else {
                                // we're going to stuff the food type information in the question_options
                                // field - probably not best practice, but we'll make do...
                                eventNotification.category = [[eventResponse objectForKey:@"question_options"] firstObject];
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

- (void)displayFoodNotification:(NSNotification *)notification
{
    BFUser *user = [BFUser fetchUser];
    if (user.foodNotifications.boolValue) {
        UILocalNotification *foodNotification = [[UILocalNotification alloc] init];
        CLLocation *currentLocation = self.locationManager.location;
        BFFoodReport *foodReport = [notification.userInfo objectForKey:@"report"];
        CLLocation *foodLocation = [[CLLocation alloc] initWithLatitude:foodReport.lat.doubleValue longitude:foodReport.lng.doubleValue];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setLocale:[NSLocale currentLocale]];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:1];
        if ([foodReport.foodDrink isEqualToString:@"drink"]) {
            foodNotification.alertBody = [NSString stringWithFormat:@"%@ was reported on floor %@ of Ford, %@ meters away!", foodReport.drinkType, foodReport.floorNumber,  [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[foodLocation distanceFromLocation:currentLocation]]]];
        } else {
            foodNotification.alertBody = [NSString stringWithFormat:@"%@ was reported on floor %@ of Ford, %@ meters away!", foodReport.foodType, foodReport.floorNumber,  [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[foodLocation distanceFromLocation:currentLocation]]]];
        }
        [[UIApplication sharedApplication] presentLocalNotificationNow:foodNotification];
    }
}

-(void)presentAlertViewFromVisibleController
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Is there food nearby?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Maybe", @"Yes", nil];
    [alertView show];
}

@end
