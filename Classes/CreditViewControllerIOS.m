//
//  CreditViewControllerIOS.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/14/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "CreditViewControllerIOS.h"

#import "RepositionSubviews.h"

@implementation CreditViewControllerIOS

@synthesize portrait;
@synthesize landscape;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
	self.title = @"About";
	
	NSBundle *bundle = [NSBundle mainBundle];
	
	NSString *version = (NSString*) [bundle objectForInfoDictionaryKey: @"CFBundleVersion"];
	
	version = [NSString stringWithFormat: @"Version %@", version];
	
	UILabel* versionLabel = ((UILabel*)[self.view viewWithTag: 22]);
	
	versionLabel.text = version;
	
	return;
}

- (IBAction) website: (id) sender
{
	NSURL *url = [NSURL URLWithString: @"http://www.dulcineatech.com/"];
	
	if ( ![[UIApplication sharedApplication] openURL: url] ){
		printf( "Failed to open\n" );
	}
	
	return;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

	[self layoutItems];
	
	return;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
	[self layoutItems];
	
	return;
}

- (void) layoutItems
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	UIView *creditTemplate = NULL;
	
	switch ( orientation ){
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			
			creditTemplate = self.landscape;			
			break;
			
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			
			creditTemplate = self.portrait;			
			break;
			
		default:
			return;
			
	}
	
	repositionSubviews( self.view, creditTemplate );
	
	[self.view setNeedsDisplay];
	
	return;
}

@end
