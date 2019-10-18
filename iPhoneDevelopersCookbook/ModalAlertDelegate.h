//
//  ModalAlert.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate> {
	CFRunLoopRef	currentLoop;
	NSUInteger	index;
	NSString	*text;
	UITextView	*textView;
}

enum{
	kTextFieldTag = 1500
};


@property (readonly) NSUInteger index;
@property (copy, nonatomic) NSString *text;

- (id) initWithRunLoop: (CFRunLoopRef) runLoop;
- (void) alertView: (UIAlertView*) aView clickedButtonAtIndex: (NSInteger) anIndex;
- (void) moveAlert: (id) arg;
- (BOOL) isLandscape;
// - (void)textViewDidEndEditing:(UITextView *)textView;
/* - (BOOL)textField: (UITextField *) textField 
 *shouldChangeCharactersInRange: (NSRange) range 
 *replacementString: (NSString *) string;
 */

@end
