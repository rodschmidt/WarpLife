//
//  SetupViewController.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "SetupViewControllerIOS.h"

#import "LifeGrid.h"
#import "LifeDisplay.h"
#import "RepositionSubviews.h"
#import "SetupView.h"
#include "ModalAlert.h"
#import "ManualViewControllerIOS.h"

@implementation SetupViewControllerIOS

@synthesize grid;
@synthesize portrait;
@synthesize landscape;
@synthesize shakeToRandomizeSwitch;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
	self.title = @"Settings";
	
	NSString *width = [NSString stringWithFormat: @"%ld", [self.grid width]];
	
	mWidth.text = width;
	mWidth.delegate = self;
	
	NSString *height = [NSString stringWithFormat: @"%ld", [self.grid height]];
	
	mHeight.text = height;
	mHeight.delegate = self;
	
	return;
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	CGRect frame = self.view.frame;
	
	SetupView *setupTemplate = NULL;
	
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	
	CGRect myAppFrame;
	
	myAppFrame.origin = appFrame.origin;
	
	switch ( orientation ){
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			
			myAppFrame.origin.x = appFrame.origin.y;
			myAppFrame.origin.y = appFrame.origin.x;
			myAppFrame.size.height = appFrame.size.width;
			myAppFrame.size.width = appFrame.size.height;
			
			setupTemplate = self.landscape;			
			break;
			
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			
			myAppFrame.origin.x = appFrame.origin.x;
			myAppFrame.origin.y = appFrame.origin.y;
			myAppFrame.size.width = appFrame.size.width;
			myAppFrame.size.height = appFrame.size.height;
			
			setupTemplate = self.portrait;			
			break;
			
		default:
			return;
	}
	
	if ( NULL == setupTemplate )
		return;

	frame.origin = myAppFrame.origin;
	frame.size.height = myAppFrame.size.height;
	frame.size.width = myAppFrame.size.width;
	
	//self.view.frame = frame;
		
	repositionSubviews( self.view, setupTemplate );
	
	[self.view setNeedsDisplay];
	
	return;
}

#if 0
- (void) setGrid: (LifeGrid*) newGrid
{
	grid = newGrid;

	return;
}
#endif

- (void) initControls
{
	if ( self.grid.shakeToRandomize == YES ){
		[self.shakeToRandomizeSwitch setOn: YES animated: NO];
	}else{
		[self.shakeToRandomizeSwitch setOn: NO animated: NO];
	}
	
	return;
}

- (IBAction) resize: (id) sender
{
	[self resizeCommon];
	
	if ( [self respondsToSelector: @selector( dismissViewControllerAnimated:completion: )] ){
        [[self parentViewController] dismissViewControllerAnimated: YES completion: ^(void){ return; } ];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        [[self parentViewController] dismissModalViewControllerAnimated: YES];
#pragma clang diagnostic pop
    }
    
    return;
}


- (IBAction) new: (id) sender
{
	[self resizeCommon];
	
	[self.grid clearAll];
	
	self.grid.edited = YES;

	[self.grid.display setNeedsDisplay];

    if ( [self respondsToSelector: @selector( dismissViewControllerAnimated:completion: )] ){
        [[self parentViewController] dismissViewControllerAnimated: YES completion: ^(void){ return; } ];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        [[self parentViewController] dismissModalViewControllerAnimated: YES];
#pragma clang diagnostic pop
    }
    
    return;
}

- (IBAction) shakeToRandomize: (id) sender
{
	if ( ( (UISwitch*) sender ).on ){
		
		self.grid.shakeToRandomize = YES;
	}else{
		self.grid.shakeToRandomize = NO;
	}
	
	return;
}

- (void) resizeCommon
{
	NSString *text = mWidth.text;
	
	int newWidth = [text intValue];
	
	text = mHeight.text;
	
	int newHeight = [text intValue];
	
	long oldHeight = self.grid.height;
	long oldWidth = self.grid.width;
	
	if ( newWidth == oldWidth && newHeight == oldHeight )
		return;
	
	if ( ![self.grid resize: newWidth height: newHeight] ){
		[ModalAlert okAlert: @"Try a smaller grid size." title: @"Insufficient Memory"];
		return;
	}
		
	self.grid.display.scale = [self.grid.display pinScale: self.grid.display.scale];

	CGPoint origin;
	origin.x = self.grid.display.origin.x + ( ( newWidth - oldWidth ) / 2 );
	origin.y = self.grid.display.origin.y + ( ( newHeight - oldHeight ) / 2 );
	
	origin = [self.grid.display pinOrigin: origin];
	
	self.grid.display.origin = origin;
	
	[self.grid.display setNeedsDisplay];

	return;
}

- (IBAction) ok: (id) sender
{
	return;
}

- (IBAction) cancel: (id) sender
{
    if ( [self respondsToSelector: @selector( dismissViewControllerAnimated:completion: )] ){
        [[self parentViewController] dismissViewControllerAnimated: YES completion: ^(void){ return; } ];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        [[self parentViewController] dismissModalViewControllerAnimated: YES];
#pragma clang diagnostic pop
    }
	
	return;
}

- (IBAction) manual: (id) sender
{    
	ManualViewControllerIOS *manualViewController = [[[ManualViewControllerIOS alloc]
            initWithNibName: @"ManualViewController_iPhone"
            bundle: nil]
                autorelease];
	    
	[self.navigationController pushViewController: manualViewController animated: YES];

	return;
}

- (BOOL)textField: (UITextField *) textField 
shouldChangeCharactersInRange: (NSRange) range 
replacementString: (NSString *) string
{
	if ( [string length] == 0 ){
		// The backspace is a zero-length "string",
		// probably some private subclass of NSString.
		
		return YES;
	}
	
	if ( [string isEqualToString: @"\n"] ){
		[textField resignFirstResponder];
		return NO;
	}
	
	if ( [string isEqualToString: @"0"]
		|| [string isEqualToString: @"1"]
		|| [string isEqualToString: @"2"]
		|| [string isEqualToString: @"3"]
		|| [string isEqualToString: @"4"]
		|| [string isEqualToString: @"5"]
		|| [string isEqualToString: @"6"]
		|| [string isEqualToString: @"7"]
		|| [string isEqualToString: @"8"]
		|| [string isEqualToString: @"9"] ){
		
		return YES;
	}

	return NO;
}

- (void) closeIt: (UIViewController*) viewController
{
    if ( [self respondsToSelector: @selector( dismissViewControllerAnimated:completion: )] ){
        [[self parentViewController] dismissViewControllerAnimated: NO completion: ^(void){ return; } ];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        [self dismissModalViewControllerAnimated: NO];
#pragma clang diagnostic pop
    }

	return;
}

@end
