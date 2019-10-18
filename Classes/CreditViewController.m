//
//  CreditViewController.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/11/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "CreditViewController.h"

#import "RepositionSubviews.h"

@implementation CreditViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	return;
}

#if 0
- (BOOL)shouldAutorotate
{
    return YES;
}
#endif

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    // Deprecated in iOS 6.0

	return ( ( interfaceOrientation == UIDeviceOrientationPortrait )
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeLeft )
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeRight ));
}

@end
