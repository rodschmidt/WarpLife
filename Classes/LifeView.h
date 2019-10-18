//
//  LifeView.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 5/1/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LifeLibCocoa/LifeDisplay.h"

#import "LifeLibCocoa/GridCoord.h"
#import "LifeIPhoneViewController.h"

// @class LifeGrid;
@class LifeSelection;
@class AccelerometerHelper;
@class LifeIPhoneViewController;

@interface LifeView : LifeDisplay {
	
	CGPoint				mStartOrigin;
	long				mGeneration;
	
	NSUInteger			mTouchCount;
	NSTimeInterval		mTouchStart;
	CGPoint				mStartLocation;
	NSMutableArray		*mStartPoints;		// set of CGPoints
		
	CGPoint				saveOrigin;
	
	GridCoord			mStartSelCoord;
	int					mRotateCellCorner;
	float				mRotationAngle;
	
	int					mReflectCellSide;
	float				mReflectionDistance;

	float				mOriginalScale;
	
	float				mSaveDelay;
	
    GridCoord			mPrevEditCell;
    GridLocation		mPrevEditLocation;
		
	LifeIOSViewController	*controller;
    
    CADisplayLink       *displayLink;

    BOOL				mGridLines;
    // BOOL				_editMode;
    BOOL				mBegan;
    BOOL				mKilling;
}

@property (retain, nonatomic) IBOutlet LifeIOSViewController *controller;

@property (assign) BOOL editMode;

//- (IBAction) toggleEdit: (id) sender;

- (void) displayTick: (CADisplayLink*) link;

- (id) initWithCoder: (NSCoder*) coder;

- (void) awakeFromNib;

- (BOOL) isMultipleTouchEnabled;

- (void) touchesBegan: (NSSet*)touches withEvent: (UIEvent*)event;
- (void) touchesMoved: (NSSet*)touches withEvent: (UIEvent*)event;
- (void) touchesEnded: (NSSet*)touches withEvent: (UIEvent*)event;

- (void) touchesOneBegan: (NSSet*) touches;
- (void) touchesTwoBegan: (NSSet*) touches;

- (void) touchesOneMoved: (NSTimeInterval) when touches: (NSSet*) touches;
- (void) touchesTwoMoved: (NSTimeInterval) when touches: (NSSet*) touches;

- (void) singleTap: (NSTimeInterval) when where: (CGPoint) theWhere;
- (void) doubleTap: (NSTimeInterval) when where: (CGPoint) theWhere;

- (void) editOneMoved: (NSSet*) touches;
- (BOOL) moveSelection: (GridCoord) where;

- (void) trackSelection: (NSMutableArray*) touchPoints;
- (void) rotateSelection: (NSMutableArray*) touchPoints;
- (void) reflectSelection: (NSMutableArray*) touchPoints;
- (float) angle: (CGPoint) fromPt to: (CGPoint) toPt;

- (NSMutableArray*) touchesToArray: (NSSet*) touches;

- (CGPoint) arrayToPoint: (NSMutableArray*) points atIndex: (int) index;

- (void) setGeneration: (long) newGeneration;

- (void) invalidateCell: (GridCoord) cell;

- (void) drawRect: (CGRect) rect;

- (void) drawHorizontalGridLine: (long) row from: (long) fromCol to: (long) toCol;
- (void) drawVerticalGridLine: (long) col from: (long) fromRow to: (long) toRow;

- (CGPoint) coordToPoint: (GridCoord) cell;
- (CGPoint) locationToPoint: (GridLocation) loc;
- (CGRect) coordToRect: (GridCoord) origin size: (GridCoord) theSize;

- (void) drawCell: (GridCoord) where;
- (void) drawLine: (GridCoord) where cellCount: (long) count;

- (void) drawSelection;
- (void) drawSelectionCorner: (GridCoord) where;
- (void) drawSelectionEdge: (GridLocation) where;
- (void) drawSelectionGrid;
- (void) drawRotatedSelection;
- (void) drawReflectedSelection;

- (void) restoreAffineMatrix;

- (float) distance: (CGPoint) from to: (CGPoint) theTo;


@end
