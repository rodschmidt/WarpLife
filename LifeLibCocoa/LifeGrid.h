//
//  LifeGrid.h
//  LifeOSX
//
//  Created by Michael D. Crawford on 12/3/09.
//  Copyright 2009 Dulcinea Technologies Corporation. All rights reserved.
//

//#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#import "GridCoord.h"

#include <limits.h>

#include "LifeRow.h"

@class LifeDisplay;
@class LifeSelection;
@class LifeClipboard;
@class AccelerometerHelper;

@interface LifeGrid : NSObject {

	NSDate	*startDate;
	
	LifeDisplay	*display;

	LifeRow	*mDisplayGrid;
	LifeRow	*mScratchGrid;
	
	LifeRow *mCopyGrid;
	
    LifeSelection *selection;

	NSLock	*mLock;
	
	LifeClipboard *clipboard;
	long height;
	long width;
	
    
    uint64_t tickTime;
    
    CADisplayLink   *displayLink;
    NSRunLoop       *runLoop;
    long            maxGens;
    long            throttleGens;
    NSLock          *genCounterLock;
    AccelerometerHelper	*mAccelerometer;
 
    BOOL shakeToRandomize;

    BOOL            mRunning;
    BOOL            mDelayed;
    double           mElapsedTime;
    NSCondition     *mSpeedCondition;
    BOOL            speedCalibrated;
    BOOL            edited;
    
}

@property (retain, nonatomic) IBOutlet LifeDisplay *display;
@property (retain) LifeSelection *selection;
@property (retain, nonatomic) LifeClipboard *clipboard;
@property (assign) long height;
@property (assign) long width;
@property (assign, nonatomic) float speed;
@property (assign) BOOL edited;
@property (assign) BOOL shakeToRandomize;
@property (assign) uint64_t tickSum;
@property (assign) double tickAverage;
@property (assign) uint64_t tickSamples;
@property (assign, nonatomic) long gensPerRefresh;

+ (void) runThread: (id) param;

- (void) dealloc;

- (IBAction) start: (id) sender;
- (IBAction) stop: (id) sender;
- (IBAction) step: (id) sender;

// - (LifeSelection*) selection;
// - (void) setSelection: (LifeSelection*) newSelection;

- (void) cut;
- (void) copyToClipboard;
- (void) paste;
- (void) clearSelection;

- (void) lock;
- (void) unlock;

- (BOOL) running;
- (void) setRunning: (BOOL) isRunning;

//- (long) generation;
//- (void) setGeneration: (long) newGeneration;
//- (void) incrementGeneration;

#if 0
- (long) height;
- (void) setHeight: (long) height;

- (long) width;
- (void) setWidth: (long) width;
#endif

- (void) copyGrid;

- (BOOL) resize: (long) newWidth height: (long) newHeight;

- (void) cycleContinuously;
- (void) tick;

- (void) toggle: (GridCoord) where;
- (void) setCell: (GridCoord) where state: (BOOL) alive;

- (LifeRow*) cells;
//- (void) setCells: (LifeRow*) cells width: (long) width height: (long) height;

- (void) merge: (LifeGrid*) grid where: (GridCoord) where;

- (void) clearAll;

- (BOOL) state: (GridCoord) cell;

- (LifeRow) getRow: (long) row;

- (LifeRow) getStartRow: (long) row;

- (CellRun) nextRun: (CellRun) prevRun row: (LifeRow) currentRow;

- (BOOL) inLivingCell: (GridCoord) where;

- (BOOL) initGrid;
- (void) freeGrid: (LifeRow*) grid withSize: (GridCoord) size;
- (LifeRow*) allocGrid: (GridCoord) size;

- (void) randomize: (float) probability;

- (LifeRow*) getDisplayGrid;

- (void) startBoundingBox: (GridCoord*) originPtr size: (GridCoord*) sizePtr;
- (void) boundingBox: (GridCoord*) originPtr size: (GridCoord*) sizePtr;
- (void) boundCommon: (LifeRow*) grid origin: (GridCoord*) originPtr size: (GridCoord*) sizePtr;

- (void) shake;

- (IBAction) adjustSpeed: (id) sender;

@end
