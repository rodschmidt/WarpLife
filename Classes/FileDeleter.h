//
//  FileDeleter.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "FileListDelegate.h"

#import "FileListViewController.h"

@interface FileDeleter : NSObject <FileListDelegate> {

}

- (BOOL) doIt: (NSString*) file viewController: (FileListViewController*) viewController;

@end
