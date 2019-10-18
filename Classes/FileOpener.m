//
//  FileDeleter.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "FileOpener.h"

#import "SetupViewController.h"

#import "LifeRLEFile.h"
#import "ModalAlert.h"
#import "LifeGrid.h"
#import "LifeIOSViewController.h"

@implementation FileOpener

//@synthesize setup;

- (BOOL) doIt: (NSString*) file viewController: (FileListViewController*) viewController
{	
	NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];

	NSString *path = [docDir stringByAppendingPathComponent: file];
	
	int error;
	
	LifeGrid *grid = [LifeRLEFile alloc: path error: &error];
	//LifeGrid *grid = NULL;

	if ( grid != NULL ){
		//[(LifeIOSViewController*)[viewController parentViewController] newGrid: grid];
		//[(SetupViewControllerIOS*)[viewController parentViewController] newGrid: grid];
		//[(LifeIOSViewController*)viewController.navigationController.topViewController newGrid: grid];
		
		NSArray *vcArray = viewController.navigationController.viewControllers;
			
		LifeIOSViewController *vc = [vcArray objectAtIndex: ([vcArray count] - 2)];
		
		[vc newGrid: grid];

		grid.edited = YES;
		
		[viewController.navigationController popToRootViewControllerAnimated: YES];
	}else{
		
		NSString *title = @"Cannot Open File";
		
		NSString *message;
		
		switch( error ){
			case kFileCorrupted:
				message = @"File Corrupted";
				break;
				
			case kInsufficientMemory:
				message = @"Insufficient Memory";
				break;
				
			case kCantOpenFile:
				message = @"Unknown Reason";
				break;
				
			case kHeaderCorrupted:
				message = @"Header Corrupted";
				break;
				
			default:
				message = @"Unknown Reason";
				break;
		}
		
		[ModalAlert okAlert: message title: title];
		return NO;
	}

	BOOL result = ( grid == NULL ? NO: YES );
    
    [grid release];
    
    return result;
}

@end
