//
//  SetupViewController.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "SetupViewControllerIPad.h"

#import "CreditViewControllerIPad.h"

@implementation SetupViewControllerIPad

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	return;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return ( ( interfaceOrientation == UIDeviceOrientationPortrait )
			|| ( interfaceOrientation == UIDeviceOrientationPortraitUpsideDown )
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeLeft )
			|| ( interfaceOrientation == UIDeviceOrientationLandscapeRight ));
}

- (IBAction) credits: (id) sender
{
	CreditViewControllerIPad *creditViewController = [[[CreditViewControllerIPad alloc] init] autorelease];
	
    if ( [self respondsToSelector: @selector( presentViewController:animated:completion: )] ){
        [self presentViewController: creditViewController animated: YES completion: ^(void){ return; } ];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"     // TODO: Update this
        [self presentModalViewController: creditViewController animated: YES];
#pragma clang diagnostic pop
    }
	
	return;
}



@end
