//
//  SetupViewController.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "SetupViewController.h"

#import "CreditViewController.h"

@implementation SetupViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

	return;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return ( ( interfaceOrientation == UIDeviceOrientationPortrait )
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeLeft ) 
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeRight ) );
}

@end
