//
//  SetupView.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/30/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetupViewController;

@interface SetupView : UIView {

	SetupViewController *controller;
}

@property (assign) IBOutlet SetupViewController *controller;

- (id) initWithCoder: (NSCoder*) coder;

- (void) awakeFromNib;

@end
