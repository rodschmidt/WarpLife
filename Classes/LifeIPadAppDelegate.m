//
//  LifeIPhoneAppDelegate.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 5/1/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "LifeIPadAppDelegate.h"
#import "LifeIPadViewController.h"

@implementation LifeIPadAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
