//
//  LifeClipboard.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/28/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "LifeLibCocoa/GridCoord.h"
#include "LifeLibCocoa/LifeRow.h"

@class LifeSelection;
@class LifeGrid;

@interface LifeClipboard : NSObject {
	LifeRow *cells;
	
	GridCoord size;
}

@property (assign) GridCoord size;
@property (assign) LifeRow *cells;

- (id) initWithSelection: (LifeSelection*) selection;

// - (void) copy: (LifeSelection*) selection;
// - (void) paste: (LifeGrid*) mGrid;

@end
