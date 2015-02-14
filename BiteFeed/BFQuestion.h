//
//  BFEvent.h
//  BiteFeed
//
//  Created by Stephen Chan on 2/10/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFQuestion : NSObject

@property (strong, nonatomic) NSNumber *uniqueId;
@property (strong, nonatomic) NSNumber *taskId;
@property (strong, nonatomic) NSNumber *sequenceNum;
@property (strong, nonatomic) NSString *questionText;
@property (strong, nonatomic) NSArray *questionOptions;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;

@end
