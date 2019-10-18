//
//  FooAppDelegate.h
//  Foo
//
//  Created by Michael D. Crawford on 7/30/11.
//  Copyright 2011 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RootViewControllerIPad;
@class DetailViewController;

@interface WarpLifeAppDelegateIPad : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
