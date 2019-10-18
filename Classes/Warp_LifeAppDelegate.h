//
//  Warp_LifeAppDelegate.h
//  Warp Life
//
//  Created by Michael D. Crawford on 7/25/11.
//  Copyright 2011 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Warp_LifeAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

