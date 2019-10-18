//
//  LifeSelection.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/22/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LifeLibCocoa/GridCoord.h"
#import "LifeLibCocoa/LifeRow.h"

@class LifeGrid;
@class LifeClipboard;

@interface LifeSelection : NSObject {
	LifeRow     *cells;
	
	GridCoord   origin;
	GridCoord   size;
}

@property (assign) GridCoord origin;
@property (assign) GridCoord size;
@property (assign) LifeRow *cells;

- (id) init: (GridCoord) origin size: (GridCoord) theSize;
- (id) initWithClipboard: (LifeClipboard*) clipboard;

- (BOOL) allocateCells;
- (void) freeCells: (LifeRow**) cells rows: (long) theRows;

- (void) dealloc;

- (BOOL) grabCells: (LifeGrid*) grid;
- (void) dropCells: (LifeGrid*) grid;

- (int) inCorner: (GridCoord) cell;
- (int) inSideHandle: (GridCoord) cell;
- (int) inSideHandleLocation: (GridLocation) loc;

- (void) rotateRight;
- (void) rotateLeft;

- (void) reflectVertical;
- (void) reflectHorizontal;

- (BOOL) inside: (GridCoord) where;
- (BOOL) insideLocation: (GridLocation) where;

@end
