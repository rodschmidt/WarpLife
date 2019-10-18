//
//  ModalAlert.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "ModalAlert.h"
#import "ModalAlertDelegate.h"

@implementation ModalAlert

+ (void) okAlert: (NSString*) message title: (NSString*) title
{
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle: title
												  message: message
												 delegate: nil
										cancelButtonTitle: @"OK"
										otherButtonTitles: nil] autorelease];
	
	[av show];
	
	return;
}

+ (NSUInteger) queryWith: (NSString*) question button1: (NSString*) button1 button2: (NSString*) button2
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	ModalAlertDelegate *maDelegate = [[ModalAlertDelegate alloc] initWithRunLoop: currentLoop];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: question message: nil delegate: maDelegate
											  cancelButtonTitle: button1 otherButtonTitles: button2, nil];
	
	[alertView show];
	
	CFRunLoopRun();
	
	NSUInteger answer = maDelegate.index;
	
	[alertView release];
	[maDelegate release];
	
	return answer;
}

+ (NSString*) copyAnswerFor: (NSString*) question 
					 prompt: (NSString*) prompt 
					button1: (NSString*) button1 
					button2: (NSString*) button2
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	ModalAlertDelegate *maDelegate = [[ModalAlertDelegate alloc] initWithRunLoop: currentLoop];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: question message: @"\n" delegate: maDelegate
											  cancelButtonTitle: button1 otherButtonTitles: button2, nil];
	
	UITextField *tf = [[UITextField alloc] initWithFrame: CGRectMake( 0.0f, 0.0f, 260.0f, 30.0f )];
	
	tf.borderStyle = UITextBorderStyleRoundedRect;
	tf.tag = kTextFieldTag;
	tf.placeholder = prompt;
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.keyboardType = UIKeyboardTypeAlphabet;
	tf.keyboardAppearance = UIKeyboardAppearanceAlert;
	tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
	tf.autocorrectionType = UITextAutocorrectionTypeNo;
	tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//tf.text = prompt;
	
	[alertView show];
	
	while ( CGRectEqualToRect( alertView.bounds, CGRectZero) );
	
	CGRect bounds = alertView.bounds;
	tf.center = CGPointMake( bounds.size.width / 2.0f, bounds.size.height / 2.0f - 10.0f );
	
	[alertView addSubview: tf];
	[tf release];
	
	[maDelegate performSelector: @selector( moveAlert: ) withObject: alertView afterDelay: 0.7f];
	
	CFRunLoopRun();
	
	NSUInteger index = maDelegate.index;
	
	NSString *answer = [maDelegate.text copy];
	
	if ( index == 0 ){
		[answer release];
		answer = nil;
	}
	
	[alertView release];
	[maDelegate release];
	
	return answer;
}

+ (BOOL) confirm: (NSString*) statement
{
	return [ModalAlert queryWith: statement button1: @"Cancel" button2: @"OK"];
}

+ (BOOL) ask: (NSString*) question
{
	return ( [ModalAlert queryWith: question button1: @"Yes" button2: @"No"] == 0 );
}

+ (NSString*) copyAnswerFor: (NSString*) question 
   withTextPrompt: (NSString*) prompt
{
	return [ModalAlert copyAnswerFor: question 
							  prompt: prompt 
							 button1: @"Cancel" 
							 button2: @"OK"];
}

@end
