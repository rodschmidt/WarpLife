//
//  ModalAlert.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "ModalAlertDelegate.h"


@implementation ModalAlertDelegate

@synthesize index;
@synthesize text;

- (id) initWithRunLoop: (CFRunLoopRef) runLoop
{
	if ( ( self = [super init] ) ){
		currentLoop = runLoop;
	
		textView = NULL;
	}
	
	return self;
}

- (void) alertView: (UIAlertView*) aView clickedButtonAtIndex: (NSInteger) anIndex
{
	index = anIndex;
	
	if ( textView )
		self.text = textView.text;

	CFRunLoopStop( currentLoop );
	
	return;
}

- (void) moveAlert: (id) arg
{	
	UIAlertView *alertView = (UIAlertView*)arg;

	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[UIView beginAnimations: nil context: context];
	
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	
	[UIView setAnimationDuration: 0.25f];
	
	if ( ![self isLandscape] ){
		alertView.center = CGPointMake( 160.0f, 180.0f );
	}else{
		alertView.center = CGPointMake( 240.0f, 90.0f );
	}
	
	[UIView commitAnimations];
	
	textView = (UITextView*)[alertView viewWithTag: kTextFieldTag];
	
	[textView becomeFirstResponder];
	
	return;
}

- (BOOL) isLandscape
{
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	
	return UIDeviceOrientationIsLandscape( orientation );
}

#if 0
- (BOOL)textField: (UITextField *) textField 
shouldChangeCharactersInRange: (NSRange) range 
replacementString: (NSString *) string
{
	if ( [string isEqualToString: @"\n"] ){

		self.text = textView.text;
		
		CFRunLoopStop( currentLoop );

		return NO;
	}
	
	return YES;
}
#endif

#if 0
- (void)textViewDidEndEditing:(UITextView *)textView
{
	self.text = textView.text;

	return;
}
#endif

@end
