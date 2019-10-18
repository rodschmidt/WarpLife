//
//  LifeIOSViewController.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/9/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LifeGrid;
@class LifeView;

@interface LifeIOSViewController : UIViewController <UIActionSheetDelegate> {
	
	IBOutlet LifeView *mView;
	
	IBOutlet UIButton *mStartButton;
	
	IBOutlet UIButton *mCopyButton;
	IBOutlet UIButton *mCutButton;
	IBOutlet UIButton *mPasteButton;
	IBOutlet UIButton *mClearButton;
    
    IBOutlet UISlider *mSpeedSlider;
	
	UIView	*mButtonView;
	
	LifeGrid	*grid;
	UIView		*controlView;
	UIView		*editView;
	UIView		*controlViewPortrait;
	UIView		*controlViewLandscape;
	UIView		*editViewPortrait;
	UIView		*editViewLandscape;
	UIImage		*startImage;
	UIImage		*pauseImage;
	
}

@property (retain, nonatomic) IBOutlet LifeGrid *grid;

@property (retain, nonatomic) IBOutlet UIView *controlView;
@property (retain, nonatomic) IBOutlet UIView *editView;

@property (retain, nonatomic) IBOutlet UIView *controlViewPortrait;
@property (retain, nonatomic) IBOutlet UIView *controlViewLandscape;

@property (retain, nonatomic) IBOutlet UIView *editViewPortrait;
@property (retain, nonatomic) IBOutlet UIView *editViewLandscape;

@property (retain, nonatomic) UIImage *startImage;
@property (retain, nonatomic) UIImage *pauseImage;

- (void) viewDidLoad;

- (void) viewWillAppear: (BOOL) animatated;

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation;

- (void) layoutItems;

- (IBAction)toggleRunning: (id) sender;

- (void) toggleEditMode;

- (void) credits: (id) sender;

- (IBAction) setup: (id) sender;

enum {
	fmDelete = 0,
	fmOpen,
	fmSave,
	fmSaveStart,
	fmCancel
};

- (IBAction) fileManagerMenu: (id) sender;
- (void) actionSheet: (UIActionSheet*)actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex;

- (IBAction) doSave: (id) sender;
- (IBAction) saveStart: (id) sender;
- (void) saveCommon: (BOOL) writeStart;
- (IBAction) open: (id) sender;
- (IBAction) doDelete: (id) sender;
- (IBAction) new: (id) sender;

// - (NSString*) documentDirectoryPath;

- (void) installControlView;
- (void) installEditView;

- (float) getLifeViewHeight;

- (void) enableEditButtons;

- (IBAction) doCut: (id) sender;
- (IBAction) copyToClipboard: (id) sender;
- (IBAction) doPaste: (id) sender;
- (IBAction) doClear: (id) sender;

- (void) newGrid: (LifeGrid*) newGrid;

@end
