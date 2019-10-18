//
//  LifeIPhoneAppDelegate.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 5/1/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LifeIPhoneViewController;

@interface LifeIPhoneAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LifeIPhoneViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LifeIPhoneViewController *viewController;

@end

