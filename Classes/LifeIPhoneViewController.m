//
//  LifeIPhoneViewController.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 5/1/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "LifeIPhoneViewController.h"

#import "LifeLibCocoa/LifeGrid.h"
#import "LifeView.h"
#import "SetupViewController.h"
#import "AllSubviews.h"
#include "CreditViewController.h"

@implementation LifeIPhoneViewController

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

- (IBAction) setup: (id) sender
{
	[super setup: sender];

	SetupViewController *setupViewController = [[[SetupViewController alloc] init] autorelease];
	
	setupViewController.grid = self.grid;

	[self.navigationController pushViewController: setupViewController animated: YES];
	
	[setupViewController initControls];

	return;
}

- (IBAction) credits: (id) sender
{
    [super credits: sender];

	CreditViewController *creditViewController = [[[CreditViewController alloc]
                                                      initWithNibName: @"CreditViewController"
                                                      bundle: nil]
                                                     autorelease];

	// CreditViewController *creditViewController = [[[CreditViewController alloc] init] autorelease];
	
	[self.navigationController pushViewController: creditViewController animated: YES];
    
	return;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    [super viewDidUnload];
    
    return;
}


- (void)dealloc {
    [super dealloc];
}

@end
