//
//  BFUser.h
//  BiteFeed
//
//  Created by Stephen Chan on 2/4/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFUser : NSManagedObject

@property (strong, nonatomic) NSNumber *uniqueId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *foodNotifications;
@property (strong, nonatomic) NSNumber *verifyReports;
@property (strong, nonatomic) NSNumber *dailyReminders;

+(BFUser *)fetchUser;
+(void)updateSettings;

@end
