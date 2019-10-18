//
//  FileDeleter.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "FileDeleter.h"

#include <UIKit/UIKit.h>

#import "SetupViewController.h"
#import "FileListViewController.h"

@implementation FileDeleter

//@synthesize setup;

- (BOOL) doIt: (NSString*) file viewController: (FileListViewController*) viewController
{
	NSError *err = [[NSError alloc] init];
	
	NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];

	NSString *path = [docDir stringByAppendingPathComponent: file];
	
	BOOL success = [[NSFileManager defaultManager]
					removeItemAtPath: path error: &err];
	
	if ( success ){
		
		[viewController remove: file];
	
		[viewController.tableView reloadData];
	}
	
	return success;
}

@end
