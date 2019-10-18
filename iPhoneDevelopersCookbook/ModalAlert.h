//
//  ModalAlert.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModalAlert : NSObject {

}

+ (void) okAlert: (NSString*) message title: (NSString*) title;
+ (NSUInteger) queryWith: (NSString*) question button1: (NSString*) button1 button2: (NSString*) button2;
+ (NSString*) copyAnswerFor: (NSString*) question 
					 prompt: (NSString*) prompt 
					button1: (NSString*) button1 
					button2: (NSString*) button2;
+ (BOOL) ask: (NSString*) question;
+ (NSString*) copyAnswerFor: (NSString*) question withTextPrompt: (NSString*) prompt;
+ (BOOL) confirm: (NSString*) statement;


@end
