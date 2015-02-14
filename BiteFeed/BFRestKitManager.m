//
//  BFRestKitManager.m
//  WingMan
//
//  Created by Stephen Chan on 9/4/14.
//  Copyright (c) 2014 TukoApps. All rights reserved.
//
// Manages all RestKit configuration of the application

#import "BFRestKitManager.h"
#import "BFQuestion.h"
#import "BFUser.h"
#import <RestKit/CoreData.h>

// set the API URL dynamically based on environment
#define LOCAL_URL (@"http://gazetapshare.herokuapp.com/api/v1/")
#define LOCAL_URL (@"http://localhost:3000/api/v1/")

@implementation BFRestKitManager

+(BFRestKitManager *)sharedManager
{
    static BFRestKitManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[BFRestKitManager alloc] init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initRKObjectManagerAndRouter];
        [self initRKObjectMappings];
        [self initCoreData];
        [self initRKEntityMappings];
    }
    return self;
}

-(void)initCoreData
{
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *error;
    [managedObjectStore createPersistentStoreCoordinator];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:self.persistentStorePath
                                                                     fromSeedDatabaseAtPath:nil
                                                                          withConfiguration:nil
                                                                                    options:@{
                                                                                              NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                                                                              NSInferMappingModelAutomaticallyOption : @(YES),
                                                                                              }
                                                                                      error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    [RKObjectManager sharedManager].managedObjectStore = managedObjectStore;
}

-(void)initRKObjectManagerAndRouter
{
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:LOCAL_URL]];
    RKRouter *router = [[RKRouter alloc] initWithBaseURL:[NSURL URLWithString:LOCAL_URL]];
    objectManager.router = router;
}

-(void)initRKObjectMappings
{
    [self initBFVerifiedFoodReportObjectMapping];
    [self initBFFoodReportObjectMapping];
    [self initBFQuestionObjectMapping];
    [self initBFUserObjectMapping];
    [self initBFUserUpdateObjectMapping];
}

-(void)initRKEntityMappings
{
    [self initBFUserEntityMapping];
}

#pragma mark - Core Data Stack setup

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        NSURL *storeUrl = [NSURL fileURLWithPath:self.persistentStorePath];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        NSError *error = nil;
        NSDictionary *options =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSPersistentStore *persistentStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
        NSAssert3(persistentStore != nil, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    return _persistentStoreCoordinator;
}

- (NSString *)persistentStorePath {
    if (_persistentStorePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths lastObject];
        _persistentStorePath = [documentsDirectory stringByAppendingPathComponent:@"BiteFeed.sqlite"];
    }
    return _persistentStorePath;
}

- (NSManagedObjectContext *)managedObjectContext
{
    static NSManagedObjectContext *managedObjectContext = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    static dispatch_once_t oncePredicate;
    if (coordinator != nil) {
        dispatch_once(&oncePredicate, ^{
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
            [managedObjectContext setUndoManager:nil];
        });
    }
    return managedObjectContext;
}

-(void)initBFUserEntityMapping
{
    RKEntityMapping* userEntityMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
   /*[userEntityMapping addAttributeMappingsFromDictionary:@{
                                                       @"id": @"uniqueId",
                                                       @"username": @"username",
                                                         @"email": @"email",
                                                         @"foodNotifications": @"foodNotifications",
                                                         @"verifyReports": @"verifyReports",
                                                       @"dailyReminders": @"dailyReminders"
                                                       }];*/
    [userEntityMapping addAttributeMappingsFromDictionary:@{
                                                         @"food_name": @"foodName",
                                                         @"distance": @"distance",
                                                         @"detail_location": @"detailLocation",
                                                         @"event_name" : @"eventName",
                                                         @"last_verification" : @"lastVerification",
                                                         @"amount_remaining" : @"amountRemaining"
                                                         }];
    userEntityMapping.identificationAttributes = @[ @"uniqueId" ];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userEntityMapping method:RKRequestMethodAny pathPattern:@"food_reports/verified" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

-(void)initBFVerifiedFoodReportObjectMapping
{
    RKObjectMapping *verifiedFoodReportMapping = [RKObjectMapping mappingForClass:[BFVerifiedFoodReport class]];
    [verifiedFoodReportMapping addAttributeMappingsFromDictionary:@{
                                                         @"food_name": @"foodName",
                                                         @"distance": @"distance",
                                                         @"detail_location": @"detailLocation",
                                                         @"event_name" : @"eventName",
                                                         @"last_verification" : @"lastVerification",
                                                         @"amount_remaining" : @"amountRemaining"
                                                         }];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:verifiedFoodReportMapping method:RKRequestMethodAny pathPattern:@"food_reports/verified" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

-(void)initBFFoodReportObjectMapping
{
     RKObjectMapping *foodReportMapping = [RKObjectMapping mappingForClass:[BFFoodReport class]];
    [foodReportMapping addAttributeMappingsFromDictionary:@{
                                                         @"lat": @"lat",
                                                         @"lon": @"lon"
                                                         }];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:foodReportMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

-(void)initBFQuestionObjectMapping
{
    RKObjectMapping *optionsMapping = [RKObjectMapping mappingForClass:[BFQuestionOption class]];
    [optionsMapping addPropertyMapping: [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"option"]];
    RKObjectMapping *questionMapping = [RKObjectMapping mappingForClass:[BFQuestion class]];
    [questionMapping addAttributeMappingsFromDictionary:@{
                                                       @"id": @"uniqueId",
                                                       @"task_id": @"taskId",
                                                         @"sequence_num": @"sequenceNum",
                                                         @"question_text": @"questionText",
                                                       @"created_at": @"createdAt",
                                                       @"updated_at": @"updatedAt"
                                                         }];
    [questionMapping addPropertyMapping: [RKRelationshipMapping relationshipMappingFromKeyPath:@"question_options" toKeyPath:@"questionOptions" withMapping:optionsMapping]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:questionMapping method:RKRequestMethodAny pathPattern:@"event/new" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

-(void)initBFUserObjectMapping
{
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[BFUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                       @"id": @"uniqueId",
                                                       @"username": @"username",
                                                         @"email": @"email",
                                                         @"food_notifications": @"foodNotifications",
                                                         @"verify_reports": @"verifyReports",
                                                       @"daily_reminders": @"dailyReminders"
                                                       }];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodAny pathPattern:@"users/new" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

-(void)initBFUserUpdateObjectMapping
{
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[BFUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{
                                                       @"id": @"uniqueId",
                                                       @"username": @"username",
                                                         @"email": @"email",
                                                         @"food_notifications": @"foodNotifications",
                                                         @"verify_reports": @"verifyReports",
                                                       @"daily_reminders": @"dailyReminders"
                                                       }];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodAny pathPattern:@"users/update" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager] addResponseDescriptor:responseDescriptor];
}

/*http://gaze-prod.herokuapp.com/api/v1/answers/new?answer[user_id]=%ld&answer[task_id]=%ld&answer[value]=%@*/


@end
