//
//  CreditViewController.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/11/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreditViewControllerIOS : UIViewController {
	UIView *portrait;
	UIView *landscape;
}

@property (retain, nonatomic) IBOutlet UIView *portrait;
@property (retain, nonatomic) IBOutlet UIView *landscape;

- (void) viewDidLoad;

- (void) viewWillAppear: (BOOL) animatated;

//- (IBAction) done: (id) sender;
- (IBAction) website: (id) sender;

- (BOOL)shouldAutorotate;

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation;

- (void) layoutItems;

@end
