//
//  FileListViewController.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "FileListViewController.h"

#import "SetupViewControllerIOS.h"
#import "MyIdiomCheck.h"
#import "RLEFileArray.h"

@implementation FileListViewController

- (id) initWithDelegateClass: (id) delegateClass
{
    if ( self = [super init]){
        files = [[RLEFileArray alloc] init];
        delegate = [[delegateClass alloc] init];
    }
    
    return self;
}

- (void) dealloc
{
    [files release];
    [delegate release];
    
    [super dealloc];
    
    return;
}

- (void) remove: (NSString*) file
{
    [files remove: file];
    
    return;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	if ( MyIdiomCheck() == kiPhoneIdiom ){
		return ( ( interfaceOrientation == UIDeviceOrientationPortrait )
				|| ( interfaceOrientation == UIDeviceOrientationPortraitUpsideDown )
				|| ( interfaceOrientation == UIDeviceOrientationLandscapeLeft )
				|| ( interfaceOrientation == UIDeviceOrientationLandscapeRight ));
	}else{
		return ( ( interfaceOrientation == UIDeviceOrientationPortrait )
				|| ( interfaceOrientation == UIDeviceOrientationLandscapeLeft )
				|| ( interfaceOrientation == UIDeviceOrientationLandscapeRight ));
	}
		
}

- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	CGRect frame = self.tableView.tableHeaderView.frame;
		
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	
	CGRect myAppFrame;
	
	myAppFrame.origin = appFrame.origin;
	
	switch ( orientation ){
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			
			myAppFrame.origin.x = appFrame.origin.y;
			myAppFrame.origin.y = appFrame.origin.x;
			myAppFrame.size.height = appFrame.size.width;
			myAppFrame.size.width = appFrame.size.height;
			break;
			
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			
			myAppFrame.origin.x = appFrame.origin.x;
			myAppFrame.origin.y = appFrame.origin.y;
			myAppFrame.size.width = appFrame.size.width;
			myAppFrame.size.height = appFrame.size.height;
			break;
			
		default:
			return;
			
	}
	
	frame.size.width = myAppFrame.size.width;
	
	self.tableView.tableHeaderView.frame = frame;
	
	UIView *doneButton = [self.tableView.tableHeaderView viewWithTag: 20];
			
	CGRect doneFrame = doneButton.frame;
	
	doneFrame.origin.x = ( frame.size.width - doneFrame.size.width ) / 2;
	
	doneFrame.origin.y = ( frame.size.height - doneFrame.size.height ) / 2;
		
	doneButton.frame = doneFrame;
	
	[self.view setNeedsDisplay];
	
	return;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
	return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    NSLog( @"count=%lu", (unsigned long)[files count] );

	return [files count];
}

- (UITableViewCell*) tableView: (UITableView*) view cellForRowAtIndexPath: (NSIndexPath*) path
{
	UITableViewCell *cell = [view dequeueReusableCellWithIdentifier: @"fileCell"];
	
	if ( !cell ){
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
									   reuseIdentifier: @"fileCell"] autorelease];
	}
	
	cell.textLabel.text = [files objectAtIndex: path.row];
	
	return cell;
}

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) path
{
	//[self.setup deleteFile: [files objectAtIndex: path.row]];
	
	//[self.setup performSelectorOnMainThread: self.selector withObject: [files objectAtIndex: path.row]];
	
	if ( [delegate respondsToSelector: @selector( doIt:viewController: )] ){
		id file = [files objectAtIndex: path.row];
		[delegate doIt: file viewController: self];
	}
	
	//[[self parentViewController] dismissModalViewControllerAnimated: YES];

	return;
}

- (NSString*) documentDirectoryPath
{
	return [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
}

@end
