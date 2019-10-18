//
//  AccelerometerHelper.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/22/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//
//  Adapted from iPhone Developers Cookbook by Erica Sadun
//	Recipe 14-9: Detecting Shakes Directly from the Accellerometer

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#if DEPRECATED
@interface AccelerometerHelper : NSObject <UIAccelerometerDelegate> {
#endif
    
@interface AccelerometerHelper: NSObject {  

#define UNDEFINED_VALUE 1000000.0

	float cx;
	float cy;
	float cz;
	
	float lx;
	float ly;
	float lz;
	
	float px;
	float py;
	float pz;
	
	float angleSensitivity;
	float forceSensitivity;
	
	float _lockout;
	
	NSDate *_triggerTime;
	
	id delegate;
    
    CMMotionManager *motionManager;
}

@property (assign, nonatomic) float angleSensitivity;
@property (assign, nonatomic) float forceSensitivity;

@property (assign, nonatomic) float lockout;

@property (retain, nonatomic) NSDate *triggerTime;

@property (retain, nonatomic) id delegate;

@property (strong, nonatomic, readonly) CMMotionManager *sharedManager;
- (id) init;

- (void) start;

- (void) setX: (float) aValue;
- (void) setY: (float) aValue;
- (void) setZ: (float) aValue;

- (float) dAngle;
- (float) acceleration;

- (BOOL) checkTrigger;

- (void) reset;

#if DEPRECATED
- (void) accelerometer: (UIAccelerometer*) accelerometer
		 didAccelerate: (UIAcceleration*) accelleration;
#endif

@end

@protocol AccelerometerHelperDelegate

- (void) ping;
- (void) shake;

@end

