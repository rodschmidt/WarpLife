//
//  RootViewController.h
//  Foo
//
//  Created by Michael D. Crawford on 7/30/11.
//  Copyright 2011 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewControllerIPad : UITableViewController {
    DetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
