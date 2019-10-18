//
//  SetupViewControllerIOS.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/12/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LifeGrid;
@class SetupView;

@interface SetupViewControllerIOS : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *mWidth;
	IBOutlet UITextField *mHeight;

#if 0
	LifeGrid	*grid;
	SetupView	*portrait;
	SetupView	*landscape;
	UISwitch	*shakeToRandomizeSwitch;
#endif
}

@property (assign) LifeGrid *grid;
@property (retain, nonatomic) IBOutlet SetupView *portrait;
@property (retain, nonatomic) IBOutlet SetupView *landscape;
@property (retain, nonatomic) IBOutlet UISwitch *shakeToRandomizeSwitch;

- (void) viewDidLoad;

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation;

- (void) setGrid: (LifeGrid*) grid;

- (void) initControls;

- (void) closeIt: (UIViewController*) viewController;

- (IBAction) resize: (id) sender;
- (IBAction) cancel: (id) sender;
- (IBAction) manual: (id) sender;
- (IBAction) shakeToRandomize: (id) sender;

- (void) resizeCommon;

- (BOOL)textField: (UITextField *) textField 
shouldChangeCharactersInRange: (NSRange) range 
replacementString: (NSString *) string;

@end
