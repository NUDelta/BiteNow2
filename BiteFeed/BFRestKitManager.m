//
//  BFRestKitManager.m
//  WingMan
//
//  Created by Stephen Chan on 9/4/14.
//  Copyright (c) 2014 TukoApps. All rights reserved.
//
// Manages all RestKit configuration of the application

#import "BFRestKitManager.h"

// set the API URL dynamically based on environment
#define BASE_URL (@"http://gazetapshare.herokuapp.com/api/v1/")

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
    }
    return self;
}

-(void)initRKObjectManagerAndRouter
{
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    RKRouter *router = [[RKRouter alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    objectManager.router = router;
}

-(void)initRKObjectMappings
{
    [self initBFVerifiedFoodReportObjectMapping];
    [self initBFFoodReportObjectMapping];
}

-(void)initBFVerifiedFoodReportObjectMapping
{
    RKObjectMapping *verifiedFoodReportMapping = [RKObjectMapping mappingForClass:[BFVerifiedFoodReport class]];
    [verifiedFoodReportMapping addAttributeMappingsFromDictionary:@{
                                                         @"id": @"uniqueId",
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
/*http://gaze-prod.herokuapp.com/api/v1/answers/new?answer[user_id]=%ld&answer[task_id]=%ld&answer[value]=%@*/
-(void)updateUserLocation
{
    //NSDictionary *params = @{@"user_id" : [BFUser user].uniqueId, @"lat" : [BFUser user].lat, @"lon" : [BFUser user].lon };
    NSDictionary *params = @{@"user_id" : [NSNumber numberWithInt:5], @"lat" : [NSNumber numberWithDouble:42.0478396], @"lon" : [NSNumber numberWithDouble:-87.6807489]};
    [[RKObjectManager sharedManager] getObjectsAtPath:@"locations/new" parameters:params
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"%@", mappingResult);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(error.description);
        }];
}

@end
