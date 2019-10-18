//
//  CreditViewControllerIPad.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/14/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "CreditViewControllerIPad.h"


@implementation CreditViewControllerIPad

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	return;
}


- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return ( ( interfaceOrientation == UIDeviceOrientationPortrait )
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeLeft )
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeRight )
			|| ( interfaceOrientation == UIDeviceOrientationPortraitUpsideDown ) );
}


@end
