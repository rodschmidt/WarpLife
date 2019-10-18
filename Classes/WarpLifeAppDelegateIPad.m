//
//  FooAppDelegate.m
//  Foo
//
//  Created by Michael D. Crawford on 7/30/11.
//  Copyright 2011 Microsoft. All rights reserved.
//

#import "WarpLifeAppDelegateIPad.h"


#import "RootViewControllerIPad.h"
#import "DetailViewController.h"


@implementation WarpLifeAppDelegateIPad;

//@synthesize window, splitViewController, rootViewController, detailViewController;

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
	
    return YES;
}

#if 0
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch.
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
	// [window addSubview: rootViewController.view];
	
	// NSArray *viewControllers = [NSArray arrayWithObjects: self.rootViewController, self.detailViewController, nil];
	
	self.detailViewController = [self.splitViewController.viewControllers objectAtIndex: 1];
	
	// splitViewController.viewControllers = viewControllers;

    [window makeKeyAndVisible];
    
    return YES;
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

