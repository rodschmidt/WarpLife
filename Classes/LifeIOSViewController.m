//
//  LifeIOSViewController.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/9/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "LifeIOSViewController.h"

#include <assert.h>

#import "iPhoneDevelopersCookbook/RepositionSubviews.h"
#include "LifeGrid.h"
#include "LifeSelection.h"
#include "LifeView.h"
#import "CreditViewController.h"
#import "ModalAlert.h"
#import "LifeRLEFile.h"
#import "FileListViewController.h"
#import "FileListDelegate.h"
#import "FileDeleter.h"
#import "FileOpener.h"
#import "RLEFileArray.h"

@implementation LifeIOSViewController

@synthesize grid;

@synthesize controlView;
@synthesize editView;

@synthesize controlViewPortrait;
@synthesize controlViewLandscape;

@synthesize editViewPortrait;
@synthesize editViewLandscape;

@synthesize startImage;
@synthesize pauseImage;

- (void) viewDidLoad
{
	[super viewDidLoad];
    
    assert( nil != mSpeedSlider );
    
    [mView setSpeed: [mSpeedSlider value]];

    self.title = @"Edit";
	
	mButtonView = NULL;
	
	[mCutButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateDisabled];
	[mCopyButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateDisabled];
	[mClearButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateDisabled];
	[mPasteButton setTitleColor: [UIColor lightGrayColor] forState: UIControlStateDisabled];
	
	[mView setController: self];
	
	self.startImage = [UIImage imageWithContentsOfFile: [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"Start.png"]];
	self.pauseImage = [UIImage imageWithContentsOfFile: [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"Pause.png"]];
	
	[self installEditView];

	mView.editMode = YES;

	self.navigationItem.rightBarButtonItem.target = self;
	self.navigationItem.rightBarButtonItem.action = @selector( toggleEditMode );
	
	return;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

	[self layoutItems];

	return;
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
	[self layoutItems];
	
	return;
}

- (void) layoutItems
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	CGRect frame = mView.frame;
	
	UIView *controlTemplate = NULL;
	UIView *editTemplate = NULL;
	
	// CGRect appFrame = [UIScreen mainScreen].applicationFrame;

	CGRect appFrame = self.view.frame;
	
	CGRect myAppFrame;

	switch ( orientation ){
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:

			myAppFrame.origin.x = appFrame.origin.y;
			myAppFrame.origin.y = appFrame.origin.x;
			myAppFrame.size.height = appFrame.size.height;
			myAppFrame.size.width = appFrame.size.width;

			controlTemplate = self.controlViewLandscape;
			editTemplate = self.editViewLandscape;
			
			break;
			
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			
			myAppFrame.origin.x = appFrame.origin.x;
			myAppFrame.origin.y = appFrame.origin.y;
			myAppFrame.size.width = appFrame.size.width;
			myAppFrame.size.height = appFrame.size.height;
						
			controlTemplate = self.controlViewPortrait;
			editTemplate = self.editViewPortrait;
			
			break;
			
		default:
			return;
			
	}

	//self.view.frame = myAppFrame;
	
	//[self.view setNeedsDisplay];

	frame.origin.x = 0;
	frame.origin.y = 0;
	frame.size.height = myAppFrame.size.height - controlTemplate.frame.size.height;
	frame.size.width = myAppFrame.size.width;
	
	float saveScale = mView.scale;
	CGPoint saveOrigin = mView.origin;
	CGRect oldFrame = mView.frame;
	
	CGPoint oldCenter;
	oldCenter.x = saveOrigin.x + ( oldFrame.size.width / ( 2.0 * saveScale ) );
	oldCenter.y = saveOrigin.y + ( oldFrame.size.height / ( 2.0 * saveScale ) );
	
	mView.frame = frame;

	CGPoint newOrigin;
	
	newOrigin.x = oldCenter.x - ( frame.size.width / ( 2.0 * mView.scale ) );
	newOrigin.y = oldCenter.y - ( frame.size.height / ( 2.0 * mView.scale ) );

	mView.origin = [mView pinOrigin: newOrigin];

	frame.origin.y = [self getLifeViewHeight];
	frame.origin.x = 0;
	frame.size.width = mView.frame.size.width;
	frame.size.height = controlTemplate.frame.size.height;
	self.controlView.frame = frame;
	
	repositionSubviews( self.controlView, controlTemplate );
	
	frame = editView.frame;
	frame.origin.y = [self getLifeViewHeight];
	frame.origin.x = 0;
	frame.size.width = mView.frame.size.width;
	frame.size.height = editTemplate.frame.size.height;
	self.editView.frame = frame;
	
	repositionSubviews( self.editView, editTemplate );
	
	[mView setNeedsDisplay];
	
	return;
}

- (float) getLifeViewHeight
{
	CGRect frame = mView.frame;
	
	return frame.origin.y + frame.size.height;
}

- (void) stop
{
	[mStartButton setImage: self.startImage forState: UIControlStateNormal];
	
	[self.grid stop: nil];

	return;
}

- (IBAction) toggleRunning: (id) sender
{
	if ( [self.grid running] ){

		[self stop];
		
	}else{
		//[sender setTitle: @"Stop" forState: UIControlStateNormal];
		//[mStartButton setTitle: @"Stop" forState: UIControlStateNormal];

		[mStartButton setImage: self.pauseImage forState: UIControlStateNormal];

		[self.grid start: nil];
	}
	
	return;
}

- (void) toggleEditMode
{
	if ( mButtonView == self.controlView ){

		[self stop];

		[self installEditView];
		
		mView.editMode = YES;

		self.title = @"Edit";
		
		self.navigationItem.rightBarButtonItem.title = @"Run";
	}else{
		
		if ( self.grid.selection ){
			[self.grid.selection dropCells: self.grid];
			self.grid.selection = NULL;
		}
		
		[self installControlView];
		
		mView.editMode = NO;

		self.title = @"Run";
	
		self.navigationItem.rightBarButtonItem.title = @"Edit";
	}
	
	[mView setNeedsDisplay];
	
	return;
}

- (void) installControlView
{
	if ( mButtonView ){
		[mButtonView removeFromSuperview];
		mButtonView = NULL;
	}
	
	[self.view addSubview: self.controlView];
	
	mButtonView = self.controlView;
	
	CGRect controlFrame = self.controlView.frame;
	
	controlFrame.origin.y = [self getLifeViewHeight];
	
	self.controlView.frame = controlFrame;
	
	return;
}

- (void) installEditView
{
	if ( mButtonView ){
		[mButtonView removeFromSuperview];
		mButtonView = NULL;
	}
	
	[self.view addSubview: self.editView];
	
	mButtonView = self.editView;
	
	CGRect editFrame = self.editView.frame;
	
	editFrame.origin.y = [self getLifeViewHeight];
	
	self.editView.frame = editFrame;
	
	[self enableEditButtons];
	
	return;
}

- (void) enableEditButtons
{
	BOOL toButtonState = self.grid.selection != NULL ? YES : NO;
	
	mCopyButton.enabled = toButtonState;
	mCutButton.enabled = toButtonState;
	mClearButton.enabled = toButtonState;
	
	if ( self.grid.clipboard ){
		mPasteButton.enabled = YES;
	}else{
		mPasteButton.enabled = NO;
	}
	
	[self.editView setNeedsDisplay];
	
	return;
}

- (IBAction) doCut: (id) sender
{
	[self.grid cut];
	
	[self enableEditButtons];
	
	return;
}

- (IBAction) copyToClipboard: (id) sender
{
	[self.grid copyToClipboard];
	
	[self enableEditButtons];
	
	return;
}

- (IBAction) doPaste: (id) sender
{
	[self.grid paste];
	
	[self enableEditButtons];
	
	return;
}

- (IBAction) doClear: (id) sender
{
	[self.grid clearSelection];
	
	[self enableEditButtons];
	
	return;
}

- (void) setup: (id) sender
{
	if ( [grid running] )
		[self toggleRunning: sender];
	
	return;
}

- (void) credits: (id) sender
{
	if ( [grid running] )
		[self toggleRunning: sender];
	
	return;
}

- (IBAction) new: (id) sender
{
	[grid clearAll];
	
	self.grid.selection = nil;
	
	[self enableEditButtons];

	[mView setNeedsDisplay];

	return;
}

- (IBAction) fileManagerMenu: (id) sender
{
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle: @"File Management"
													  delegate: self
											 cancelButtonTitle: @"Cancel"
										destructiveButtonTitle: @"Delete File"
											 otherButtonTitles: @"Open", @"Save", @"Save Start", nil];
	[menu showInView: self.view];
	
	[menu release];
	
	return;
}

- (void) actionSheet: (UIActionSheet*)actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex
{
	SEL sel;
	
	switch ( buttonIndex ){
		case fmDelete:
			sel = @selector( delete: );
			break;
			
		case fmOpen:
			sel = @selector( open: );
			break;
			
		case fmSave:
			sel = @selector( doSave: );
			break;

		case fmSaveStart:
			sel = @selector( saveStart: );
			break;
			
		case fmCancel:
			// do nothing;
			return;
			
		default:
			assert( false );
			break;
	}

	[self performSelector: sel withObject: nil afterDelay: 0.5f];

	return;
}

- (IBAction) doSave: (id) sender
{
	[self saveCommon: NO];
	
	return;
}

- (IBAction) saveStart: (id) sender
{
	[self saveCommon: YES];
	
	return;
}

- (void) saveCommon: (BOOL) writeStart
{
	
	NSString *path = nil;
	
	do {
		NSString *baseName = [ModalAlert copyAnswerFor: @"File Name?" withTextPrompt: @"Untitled"];
		
		if ( baseName == nil )
			return;
		
		NSString *fileName;
		
		if ( ![baseName hasSuffix: @".rle"] ){
			fileName = [baseName stringByAppendingString: @".rle"];
		}else{
			fileName = baseName;
		}
		
		NSString *docDir = [self documentDirectoryPath];
		
		path = [docDir stringByAppendingPathComponent: fileName];

		[baseName release];
		
		if ( [[NSFileManager defaultManager] isWritableFileAtPath: path] ){
			if ( [ModalAlert queryWith: @"Replace existing file?" button1: @"Cancel" button2: @"Replace"] ){
				if ( [[NSFileManager defaultManager] removeItemAtPath: path error: nil] )
					break;
			}else{
				return;
			}
		}else{
			break;
		}
	}while( YES );
	
	[LifeRLEFile write: self.grid path: path start: writeStart];

	return;
}

- (NSString*) documentDirectoryPath
{
    // STUB there are two documentDirectoryPaths.  Get rid of one.

	return [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
}

- (IBAction) open: (id) sender
{
	FileListViewController *fileList = [[FileListViewController alloc]
                                        initWithDelegateClass: [FileOpener class]];
    
	fileList.title = @"Open Document";

	[self.navigationController pushViewController: fileList animated: YES];

	[fileList release];
	
	return;
}

- (IBAction) doDelete: (id) sender
{
	FileListViewController * fileList = [[FileListViewController alloc]
                                            initWithDelegateClass: [FileDeleter class]];
	
	fileList.title = @"Delete Document";
	
	[self.navigationController pushViewController: fileList animated: YES];
	
	[fileList release];
	
	return;
}

- (void) newGrid: (LifeGrid*) newGrid
{
	//[self.grid setCells: [newGrid cells] width: [newGrid width] height: [newGrid height]];
	
	GridCoord where;
	
	where.col = ( [self.grid width] - [newGrid width] ) / 2;
	where.row = ( [self.grid height] - [newGrid height] ) / 2;
	
	[self.grid clearAll];
	
	[self.grid merge: newGrid where: where];
	
	[[self.grid display] centerImage];
	
	// [[self parentViewController] dismissModalViewControllerAnimated: YES];
	
	return;
}

@end
