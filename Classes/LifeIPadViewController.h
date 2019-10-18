//
//  LifeIPhoneViewController.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 5/1/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LifeIOSViewController.h"

@class LifeGrid;
@class LifeView;

@interface LifeIPadViewController : LifeIOSViewController {
	
}

- (void) viewDidLoad;

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation;

- (IBAction) setup: (id) sender;

- (IBAction) credits: (id) sender;

@end

