//
//  AccellerometerHelper.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/22/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//
//  Adapted from iPhone Developers Cookbook by Erica Sadun
//	Recipe 14-9: Detecting Shakes Directly from the Accellerometer

#import "AccelerometerHelper.h"

#import <UIKit/UIKit.h>

@implementation AccelerometerHelper

@synthesize triggerTime;
@synthesize lockout;
@synthesize angleSensitivity;
@synthesize forceSensitivity;
@synthesize delegate;

- (id) init
{
	if ( !(self = [super init]) )
		return self;
	
	_triggerTime = [NSDate date];
	
	cx = UNDEFINED_VALUE;
	cy = UNDEFINED_VALUE;
	cz = UNDEFINED_VALUE;
	
	lx = UNDEFINED_VALUE;
	ly = UNDEFINED_VALUE;
	lz = UNDEFINED_VALUE;
	
	px = UNDEFINED_VALUE;
	py = UNDEFINED_VALUE;
	pz = UNDEFINED_VALUE;
	
	self.angleSensitivity = 0.8f;
	self.forceSensitivity = 1.1f;
	
	lockout = 2.0f;

#if 0
	[[UIAccelerometer sharedAccelerometer] setDelegate: self];
#endif
    
	return self;
}

- (void) start
{
    CMMotionManager *manager = [self sharedManager];
    
    if ([manager isAccelerometerAvailable] == YES ){
        [manager setAccelerometerUpdateInterval: 0.10];
        [manager startAccelerometerUpdatesToQueue:
         [NSOperationQueue mainQueue] withHandler:
         ^(CMAccelerometerData *accelerometerData, NSError *error){
             
             // Adapt values for a standard coordinate system
             
             [self setX: -accelerometerData.acceleration.x];
             [self setY: accelerometerData.acceleration.y];
             [self setZ: accelerometerData.acceleration.z];
             
             // All accellerometer events
             
             if ( self.delegate && [self.delegate respondsToSelector: @selector( ping ) ])
                 [self.delegate performSelector: @selector( ping )];
             
             // All shake events
             
             if ( [self checkTrigger] &&
                 self.delegate && [self.delegate respondsToSelector: @selector( shake )])
                 [self.delegate performSelector: @selector( shake ) ];
             
         }];
    }
    
    return;
}

- (CMMotionManager*) sharedManager
{
    static dispatch_once_t onceToken;
    
    dispatch_once( &onceToken, ^{
        motionManager = [[CMMotionManager alloc] init];
    });
    
    return motionManager;
}

- (void) setX: (float) aValue
{
	px = lx;
	lx = cx;
	cx = aValue;
	
	return;
}

- (void) setY: (float) aValue
{
	py = ly;
	ly = cy;
	cy = aValue;
	
	return;
}

- (void) setZ: (float) aValue
{
	pz = lz;
	lz = cz;
	cz = aValue;
	
	return;
}

- (float) dAngle
{
	if ( cx == UNDEFINED_VALUE )
		return UNDEFINED_VALUE;
	
	if ( lx == UNDEFINED_VALUE )
		return UNDEFINED_VALUE;
	
	if ( px == UNDEFINED_VALUE )
		return UNDEFINED_VALUE;
	
	// calculate the dot product of the first pair
	
	float dot1 = cx * lx + cy * ly + cz * lz;
	float a = fabs( sqrt( cx * cx + cy * cy + cz * cz ) );
	float b = fabs( sqrt( lx * lx + ly * ly + lz * lz ) );
	dot1 /= ( a * b );
	
	// calculate the dot product of the second pair
	
	float dot2 = lx * px + ly * py + lz * pz;
	a = fabs( sqrt( px * px + py * py + pz * pz ) );
	dot2 /= ( a * b );
	
	// return the difference between the two vector angles
	
	return acos( dot2 ) - acos( dot1 );
}

- (float) acceleration
{
	float c = sqrt( cx * cx + cy * cy + cz * cz );
	float l = sqrt( lx * lx + ly * ly + lz * lz );
	float p = sqrt( px * px + py * py + pz * pz );
	
	float force = MIN( c, l );
	force = MIN( force, p );
	
	return force;
}

- (BOOL) checkTrigger
{
	if ( lx == UNDEFINED_VALUE )
		return NO;
	
	// check to see if new data can be triggered yet
	
	if ( [[NSDate date] timeIntervalSinceDate: self.triggerTime] < self.lockout )
		return NO;
	
	// get the current angular change
	float change = [self dAngle];
	
	// If we have not yet gathered two samples, return NO
	if ( change == UNDEFINED_VALUE )
		return NO;
	
	// does the dot product exceed the trigger?
	
	if ( change > self.angleSensitivity )
	{
		
		float accel = [self acceleration];
		
		if ( accel > self.forceSensitivity ){
			self.triggerTime = [NSDate date];
			return YES;
		}
	}
	
	return NO;
}

#if DEPRECATED
- (void) accelerometer: (UIAccelerometer*) accelerometer 
		 didAccelerate: (UIAcceleration*) acceleration
{
	// Adapt values for a standard coordinate system
	
	[self setX: -[acceleration x]];
	[self setY: [acceleration y]];
	[self setZ: [acceleration z]];
	
	// All accellerometer events
	
	if ( self.delegate && [self.delegate respondsToSelector: @selector( ping ) ])
		[self.delegate performSelector: @selector( ping )];
	
	// All shake events
	
	if ( [self checkTrigger] &&
		self.delegate && [self.delegate respondsToSelector: @selector( shake )])
		[self.delegate performSelector: @selector( shake ) ];
	
	return;
}
#endif // DEPRECATED

- (void) reset
{
	cx = UNDEFINED_VALUE;
	lx = UNDEFINED_VALUE;
	px = UNDEFINED_VALUE;
	
	return;
}

@end
