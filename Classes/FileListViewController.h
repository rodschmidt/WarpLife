//
//  FileListViewController.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SetupViewControllerIOS;
@class FileListViewController;
@class RLEFileArray;

@protocol FileListDelegate <NSObject>
- (BOOL) doIt: (NSString*) file viewController: (FileListViewController*) viewController;
//@property (assign) SetupViewControllerIOS *setup;
@end

@interface FileListViewController : UITableViewController {

	SetupViewControllerIOS *setup;
    RLEFileArray *files;
    id <FileListDelegate> delegate;
}

// @property (retain, nonatomic) RLEFileArray* files;
// @property (assign) SetupViewControllerIOS* setup;
// @property (retain, nonatomic) id <FileListDelegate> delegate;
// @property (assign) id <FileListDelegate> delegate;

//- (id) init;
- (id) initWithDelegateClass: (id) delegateClass;
- (void) dealloc;

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation;

- (NSString*) documentDirectoryPath;

- (void) remove: (NSString*) file;

@end
