//
//  FileListDelegate.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SetupViewControllerIOS;
@class FileListViewController;

@interface FileListDelegate : NSObject {

	SetupViewControllerIOS *setup;
}

@property (assign) SetupViewControllerIOS *setup;

- (BOOL) doIt: (NSString*) file viewController: (FileListViewController*) viewController;

@end
