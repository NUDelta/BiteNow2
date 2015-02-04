//
//  coreMotionListener.m
//  LocaleNatives
//
//  Created by Stephen Chan on 12/31/13.
//  Copyright (c) 2013 Stephen Chan. All rights reserved.
//

#import "TSCoreMotionListener.h"

@interface TSCoreMotionListener()
@property (strong, nonatomic) NSOperationQueue *deviceMeasurementsQueue;
@property (strong, readwrite) NSMutableArray *deviceMotionArray;

@end

@implementation TSCoreMotionListener

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.deviceMotionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)collectMotionInformationWithInterval:(int)interval
{
    // starts device motion manager, with interval in ms
    
    // let's get the information all out from the device motion manager at once first
    
    self.measurementInterval = [NSNumber numberWithFloat:(interval / 1000.0)];
    
    if(self.motionManager.deviceMotionAvailable){
        double intervalInMs = (((double)interval) / 1000.0);
        self.motionManager.deviceMotionUpdateInterval = intervalInMs;
        
        [self.motionManager startDeviceMotionUpdatesToQueue:self.deviceMeasurementsQueue withHandler:^(CMDeviceMotion *deviceMeasurementData, NSError *error){
            /*CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;
             //[self.deviceMotionArray addObject:deviceMotion];
             if ([self.deviceMotionArray count] > 500) {
             [self.deviceMotionArray removeObjectAtIndex:0];
             } */
            [self.delegate motionListener:self didReceiveDeviceMotion:deviceMeasurementData];
            //NSLog(@"%@", deviceMeasurementData);
        }];
        
        /*[self.motionManager startAccelerometerUpdatesToQueue:self.deviceMeasurementsQueue withHandler:^(CMAccelerometerData *data, NSError *error) {
         [self.delegate motionListener:self didReceiveAccelerometerData:data];
         }]; */
    }
}

- (void)stopCollectingMotionInformation
{
    [self.motionManager stopDeviceMotionUpdates];
}

-(CMMotionManager *)motionManager
{
    if (!_motionManager) _motionManager = [[CMMotionManager alloc] init];
    return _motionManager;
}

- (NSOperationQueue *)deviceMeasurementsQueue
{
    if (!_deviceMeasurementsQueue) {
        return [NSOperationQueue currentQueue];
    }
    return _deviceMeasurementsQueue;
}

@end
