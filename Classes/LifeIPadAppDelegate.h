//
//  LifeIPhoneAppDelegate.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 5/1/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LifeIPadViewController;

@interface LifeIPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LifeIPadViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LifeIPadViewController *viewController;

@end

