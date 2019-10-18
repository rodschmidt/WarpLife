//
//  LifeView.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 5/1/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "LifeView.h"

#import <math.h>
#import <stdio.h>
#import <mach/mach_time.h>

#import <UIKit/UIKit.h>

#import "LifeLibCocoa/LifeGrid.h"
#import "LifeLibCocoa/LifeSelection.h"

#import "LifeIPhoneViewController.h"

@implementation LifeView

@synthesize controller;
@synthesize editMode;

- (BOOL) isMultipleTouchEnabled
{
	return YES;
}

- (void) displayTick: (CADisplayLink*) link
{
    printf( "%ld ", self.grid.gensPerRefresh );
    self.grid.gensPerRefresh = 0;

    [self setNeedsDisplay];

    return;
}

- (id) initWithCoder: (NSCoder*) coder
{
	self = [super initWithCoder: coder];
	
	if ( self ){
		mGridLines = FALSE;
		mGeneration = 0;
		// editMode = FALSE;    // STUB should this be initialized?
		mStartPoints = NULL;
		
		mRotateCellCorner = -1;
		mReflectCellSide = -1;
				
		saveOrigin = self.origin;
	}
	
	return self;
}

- (void) awakeFromNib
{
	//[self.grid setDisplay: self];

    [super awakeFromNib];

    CGFloat theScale = 1.0;
    
    // Enable retina display sub-point drawing, if available
    if ( [self respondsToSelector:
          @selector( setContentScaleFactor: )] ){
        
        theScale = [[UIScreen mainScreen] scale];
        
        NSLog( @"theScale=%f", theScale );
        
        [self setContentScaleFactor: theScale];
    }
    
	self.grid.height = self.bounds.size.height * theScale;
	self.grid.width = self.bounds.size.width * theScale;
	
	[self.grid initGrid];

	return;
}

- (void) touchesBegan: (NSSet*)touches withEvent: (UIEvent*)event
{
	mTouchCount = [touches count];

	mStartOrigin = self.origin;

	mTouchStart = ((UITouch*)[touches anyObject]).timestamp;

	//printf( "%d\n", mTouchCount );

	switch( mTouchCount ){
		case 1:
			[self touchesOneBegan: touches];
			return;
			
		case 2:
			[self touchesTwoBegan: touches];
			return;
			
		default:
			return;
	}
	
	return;
}

- (void) touchesMoved: (NSSet*)touches withEvent: (UIEvent*)event
{
	NSUInteger count = [touches count];
	
	//printf( "%d\n", count );

	// The iPhone Developer's Cookbook says that multiple touches
	// are somewhat unsteady.  My own observation is that a two-finger
	// gesture will result in either one or two touches being present
	// in the NSSet, with the number being unpredictable.
	//
	// Experiment indicates that it works best to allow either one or
	// two touches at first, but if we EVER see two touches, then we
	// should start ignoring single-touch events.  Otherwise the
	// alternating dragging and pinching that would result makes the
	// screen jump about erratically.
	
	// fprintf( stderr, "%d ", count );

	if ( count == 1 && NULL != mStartPoints ){
		//printf( "*\n" );
		return;
	}

	if ( count == 1 ){
		//printf( ".\n" );
	}
	
	NSTimeInterval when = ((UITouch*)[touches anyObject]).timestamp;

	switch( count ){
		case 1:
			[self touchesOneMoved: when touches: touches];
			return;
			
		case 2:
			if ( NULL == mStartPoints ){
				mTouchStart = when;
				
				[self touchesTwoBegan: touches];
				return;
			}

			
			[self touchesTwoMoved: when touches: touches];
			return;
			
		default:
			return;
	}

	return;
}

- (void) touchesEnded: (NSSet*)touches withEvent: (UIEvent*)event
{
	//printf( "# %d\n", [touches count] );
	//printf( "# %f %f\n", self.origin.x, self.origin.y );
	
	if ( NULL != mStartPoints ){
		[mStartPoints release];
		
		mStartPoints = NULL;

#if 0
		[self.grid setDelay: mSaveDelay];
#endif
	}
	
	if ( -1 != mRotateCellCorner ){
		mRotateCellCorner = -1;
		mRotationAngle = 0.0;
		[self setNeedsDisplay];
	}
	
	if ( -1 != mReflectCellSide ){
		mReflectCellSide = -1;
		mReflectionDistance = 0.0;
		[self setNeedsDisplay];
	}
	
	saveOrigin = self.origin;

	return;
}

- (void) touchesOneBegan: (NSSet*) touches
{
	CGPoint theWhere = [[touches anyObject] locationInView: self];
	
	NSTimeInterval when = ((UITouch*)[touches anyObject]).timestamp;

	switch( [[touches anyObject] tapCount] ){
		case 1:
			[self singleTap: when where: theWhere];
			break;
			
		case 2:
			[self doubleTap: when where: theWhere];
			break;
	}
	
	// fprintf( stderr, " - %5.1f %5.1f\n", mStartLocation.x, mStartLocation.y );
	
	return;
}

- (void) singleTap: (NSTimeInterval) when where: (CGPoint) theWhere
{
	//printf( "singleTap\n" );
    
	mTouchStart = when;
	
	mStartLocation = theWhere;
	
	if ( self.editMode ){
		
        mPrevEditCell = [self pointToCoord: mStartLocation];
        mPrevEditLocation = [self pointToLocation: mStartLocation];
        
		if ( [self.grid selection] ){
			
			if ( ![self.grid.selection inside: mPrevEditCell] ){
                
				[self.grid.selection dropCells: self.grid];
                
				[self.grid setSelection: NULL];
                
				[controller enableEditButtons];
                
				[self setNeedsDisplay];
                
				return;
			}else{
                
				mRotateCellCorner = [self.grid.selection inCorner: mPrevEditCell];
				
				if ( mRotateCellCorner == -1 ){
					
					mReflectCellSide = [self.grid.selection inSideHandleLocation: mPrevEditLocation];
					
					if ( mReflectCellSide == -1 ){
                        
						mStartSelCoord = self.grid.selection.origin;
					}
				}
				
				return;
			}
            
		}
		
		
		mKilling = [self.grid inLivingCell: mPrevEditCell] ? YES : NO;
		
		[self.grid toggle: mPrevEditCell];
		[self invalidateCell: mPrevEditCell];
	}
	
	return;
}

#if 0
- (void) singleTap: (NSTimeInterval) when where: (CGPoint) theWhere
{
	//printf( "singleTap\n" );

	mTouchStart = when;
	
	mStartLocation = theWhere;
	
	if ( mEditMode ){
		
		mPrevEditCell = [self pointToCoord: mStartLocation];

		if ( self.grid.selection ){
			
			if ( ![self.grid.selection inside: mPrevEditCell] ){
							
				[self.grid.selection dropCells: self.grid];
			
				self.grid.selection = NULL;
		
				[controller enableEditButtons];

				[self setNeedsDisplay];

				return;
			}else{
		
				mRotateCellCorner = [self.grid.selection inCorner: mPrevEditCell];
				
				if ( mRotateCellCorner == -1 ){
					
					mReflectCellSide = [self.grid.selection inSideHandle: mPrevEditCell];
					
					if ( mReflectCellSide == -1 ){
					
						mStartSelCoord = self.grid.selection.origin;
					}
				}
				
				return;
			}

		}
		
		
		mKilling = [self.grid inLivingCell: mPrevEditCell] ? YES : NO;
		
		[self.grid toggle: mPrevEditCell];
		[self invalidateCell: mPrevEditCell];
	}
	
	return;
}
#endif

- (void) doubleTap: (NSTimeInterval) when where: (CGPoint) theWhere
{
#if 0
	float distance = [self distance: theWhere to: mStartLocation ];

	if ( mEditMode ){
		
		[self.grid toggle: mPrevEditCell];
	}
	
	[controller toggleEditMode];
#endif
	
	return;
}

- (void) touchesTwoBegan: (NSSet*) touches
{
	mStartPoints = [[self touchesToArray: touches] retain];
	
	if ( self.editMode ){
		
		// [self trackSelection: mStartPoints];
		[self trackSelection: mStartPoints];

	}else{
		
		mOriginalScale = self.scale;

#if 0
		mSaveDelay = [self.grid delay];

		[self.grid setDelay: 0.3];
#endif
	}
	return;
}

- (void) trackSelection: (NSMutableArray*) touchPoints
{
	if ( [touchPoints count] != 2 ){
        return;
    }

	GridCoord myOrigin;
	GridCoord size;

	CGPoint pt = [self arrayToPoint: touchPoints atIndex: 0];

	GridCoord coord1 = [self pointToCoord: pt];

	pt = [self arrayToPoint: touchPoints atIndex: 1];

	GridCoord coord2 = [self pointToCoord: pt];

	if ( coord1.row < coord2.row ){
		myOrigin.row = coord1.row;
		size.row = coord2.row - coord1.row;
	}else{
		myOrigin.row = coord2.row;
		size.row = coord1.row - coord2.row;
	}

	size.row += 1;
	
	if ( coord1.col < coord2.col ){
		myOrigin.col = coord1.col;
		size.col = coord2.col - coord1.col;
	}else{
		myOrigin.col = coord2.col;
		size.col = coord1.col - coord2.col;
	}

	size.col += 1;
	
    LifeSelection *sel;
	
    if ( self.grid.selection ){

		[self.grid.selection dropCells: self.grid];
    }
 
    sel =  [[LifeSelection alloc] init: myOrigin size: size];
    
    self.grid.selection = sel;
    
    [sel grabCells: self.grid];
    
    [sel release];

	[controller enableEditButtons];

	[self setNeedsDisplay];
	
	return;
}

- (void) rotateSelection: (NSMutableArray*) touchPoints
{
	GridCoord center;
	
	center.col = self.grid.selection.origin.col + ( self.grid.selection.size.col / 2 );
	center.row = self.grid.selection.origin.row + ( self.grid.selection.size.row / 2 );
	
	CGPoint pt = [self arrayToPoint: touchPoints atIndex: 0];
	
	GridCoord cornerLoc;
	
	switch( mRotateCellCorner ){
		case 0:
			cornerLoc = self.grid.selection.origin;
			break;
			
		case 1:
			cornerLoc.col = self.grid.selection.origin.col + self.grid.selection.size.col - 1;
			cornerLoc.row = self.grid.selection.origin.row;
			break;
			
		case 2:
			cornerLoc.col = self.grid.selection.origin.col + self.grid.selection.size.col - 1;
			cornerLoc.row = self.grid.selection.origin.row + self.grid.selection.size.row - 1;
			break;
			
		case 3:
			cornerLoc.col = self.grid.selection.origin.col;
			cornerLoc.row = self.grid.selection.origin.row + self.grid.selection.size.row - 1;
			break;

		case -2:
			return;
			
		default:
			assert( false );
			break;
	}
	
	CGPoint cornerPt = [self coordToPoint: cornerLoc];

	CGPoint centerPt = [self coordToPoint: center];

//#if 0
	if ( self.grid.selection.size.col % 2 == 1 ){
		centerPt.x += self.scale / 2.0;
	}
	if ( self.grid.selection.size.row % 2 == 1 ){
		centerPt.y += self.scale / 2.0;
	}
//#endif
	
	cornerPt.x -= centerPt.x;
	
	cornerPt.y -= centerPt.y;
	
	pt.x -= centerPt.x;

	pt.y -= centerPt.y;
	
	mRotationAngle = [self angle: cornerPt to: pt];

	float fiftyFive = 2 * M_PI * 55.0 / 360;

	if ( mRotationAngle > fiftyFive ){
		[self.grid.selection rotateLeft];
		
		mRotateCellCorner -= 1;
		if ( mRotateCellCorner == -1 )
			mRotateCellCorner = 3;
		
	}else if ( mRotationAngle < -fiftyFive ){
		[self.grid.selection rotateRight];
		
		mRotateCellCorner += 1;
		if ( mRotateCellCorner >= 4 )
			mRotateCellCorner = 0;
	}
	
	[self setNeedsDisplay];


	return;
}

- (void) reflectSelection: (NSMutableArray*) touchPoints
{
	GridCoord center;
	
	center.col = self.grid.selection.origin.col + ( self.grid.selection.size.col / 2 );
	center.row = self.grid.selection.origin.row + ( self.grid.selection.size.row / 2 );
	
	CGPoint pt = [self arrayToPoint: touchPoints atIndex: 0];
	
	GridCoord sideLoc;
	
	long halfCol = self.grid.selection.origin.col + ( self.grid.selection.size.col / 2 );
	long halfRow = self.grid.selection.origin.row + ( self.grid.selection.size.row / 2 );
	long right = self.grid.selection.origin.col + self.grid.selection.size.col - 1;
	long bottom = self.grid.selection.origin.row + self.grid.selection.size.row - 1;
	
	switch( mReflectCellSide ){
		case 0:
			sideLoc.col = halfCol;
			sideLoc.row = self.grid.selection.origin.row;
			break;
			
		case 1:
			sideLoc.col = right;
			sideLoc.row = halfRow;
			break;
			
		case 2:
			sideLoc.col = halfCol;
			sideLoc.row = bottom;
			break;
			
		case 3:
			sideLoc.col = self.grid.selection.origin.col;
			sideLoc.row = halfRow;
			break;
			
		case -2:
			return;
			
		default:
			assert( false );
			break;
	}
	
	CGPoint sidePt = [self coordToPoint: sideLoc];
	
	CGPoint centerPt = [self coordToPoint: center];
	
	//#if 0
	if ( self.grid.selection.size.col % 2 == 1 ){
		centerPt.x += self.scale / 2.0;
	}
	if ( self.grid.selection.size.row % 2 == 1 ){
		centerPt.y += self.scale / 2.0;
	}
	//#endif
	
	sidePt.x -= centerPt.x;
	
	sidePt.y -= centerPt.y;
	
	pt.x -= centerPt.x;
	
	pt.y -= centerPt.y;
	
	//printf( "%f %f\n", centerPt.x, centerPt.y );
	
	switch ( mReflectCellSide ){
		case 0:
			mReflectionDistance = pt.y;
			if ( pt.y > 10 ){
				[self.grid.selection reflectVertical];
				mReflectCellSide = 2;
			}
			break;
			
		case 2:
			mReflectionDistance = pt.y;
			if ( pt.y < -10 ){
				[self.grid.selection reflectVertical];
				mReflectCellSide = 0;
			}
			break;
			
		case 1:
			mReflectionDistance = pt.x;
			if ( pt.x < -10 ){
				[self.grid.selection reflectHorizontal];
				mReflectCellSide = 3;
			}
			break;
			
		case 3:
			mReflectionDistance = pt.x;
			if ( pt.x > 10 ){
				[self.grid.selection reflectHorizontal];
				mReflectCellSide = 1;
			}
			break;
	}
				
	[self setNeedsDisplay];
	
	
	return;
}

- (float) angle: (CGPoint) fromPt to: (CGPoint) toPt
{	
	float dot1 = fromPt.x * toPt.x + fromPt.y * toPt.y;
	
	float a = fabs( sqrt( (float)fromPt.x * fromPt.x + fromPt.y * fromPt.y ) );
	float b = fabs( sqrt( (float)toPt.x * toPt.x + toPt.y * toPt.y ) );
	dot1 /= ( a * b );
	
	float result = acos( dot1 );
	
	fromPt.x /= a;
	//fromPt.y /= a;
	
	toPt.x /= b;
	//toPt.y /= b;
	
	if ( fromPt.y > 0 ){
		
		if ( toPt.x < fromPt.x )
			result = -result;
	}else{
		if ( toPt.x > fromPt.x )
			result = -result;
	}
	
	return result;
}

- (void) touchesOneMoved: (NSTimeInterval) when touches: (NSSet*) touches
{
	NSTimeInterval delta = when - mTouchStart;
	
	mTouchStart = when;

#if 0
	if ( delta < 0.01 )
		printf( "******** " );
	
	if ( delta > 0.1 )
		printf( "........ " );

	printf( "%f\n", delta );
#endif
	
	if ( fabs( delta ) < 0.01 || fabs( delta ) > 0.1 )
		return;

	
	if ( self.editMode ){
		[self editOneMoved: touches];
		return;
	}
	
	CGPoint pt = [[touches anyObject] locationInView: self];

	// fprintf( stderr, " + %5.1f %5.1f\n", pt.x, pt.y );

	float dx = pt.x - mStartLocation.x;
	float dy = pt.y - mStartLocation.y;
		
	// We store the origin in GridCoords, not screen pixels
	
	CGPoint newOrigin;
	
	newOrigin.x = mStartOrigin.x - ( dx / self.scale );
	newOrigin.y = mStartOrigin.y - ( dy / self.scale );
	
	newOrigin = [self pinOrigin: newOrigin];

	dx = newOrigin.x - self.origin.x;
	dy = newOrigin.y - self.origin.y;
	
	float distance = self.scale * sqrt( dx * dx + dy * dy );
	if ( distance > 50 ){
		//printf( "+ %f\n", distance );
		return;
	}
	
	self.origin = newOrigin;
	
	//printf( "= %f %f\n", self.origin.x, self.origin.y );

	[self setNeedsDisplay];
	
	return;
}

- (void) editOneMoved: (NSSet*) touches;
{
	CGPoint pt = [[touches anyObject] locationInView: self];
	
	GridCoord cell = [self pointToCoord: pt];

	if ( self.grid.selection ){
		
		if ( mRotateCellCorner != -1 ){
			
			[self rotateSelection: [self touchesToArray: touches]];
		}else if ( mReflectCellSide != -1 ){
			[self reflectSelection: [self touchesToArray: touches]];
		}else{
			if ( [self moveSelection: cell] )
				return;
		}
	
		return;
	}
	
	if ( cell.row != mPrevEditCell.row || cell.col != mPrevEditCell.col ){
		
		mPrevEditCell = cell;
		
		if ( [self.grid state: mPrevEditCell] == mKilling ){
		
			[self.grid setCell: mPrevEditCell state: mKilling ? NO : YES];
			
			[self invalidateCell: mPrevEditCell];
		}
	}
	
	return;
}

- (BOOL) moveSelection: (GridCoord) where
{
	if ( [self.grid.selection inside: where] ){
		
		CGRect updateRect = [self coordToRect: self.grid.selection.origin size: self.grid.selection.size];
		
		updateRect.size.height += self.scale;
		updateRect.size.width += self.scale;
		
		CGRectInset( updateRect, -3, -3 );
		
		[self setNeedsDisplayInRect: updateRect];
		
		GridCoord startCoord = [self pointToCoord: mStartLocation];
		
		long yOff = where.row - startCoord.row;
		long xOff = where.col - startCoord.col;
		
		GridCoord selOrigin = self.grid.selection.origin;
		
		selOrigin.row = mStartSelCoord.row + yOff;
		selOrigin.col = mStartSelCoord.col + xOff;
		
		self.grid.selection.origin = selOrigin;
	
		//fprintf( stderr, "%d %d\n", self.selection.origin.col, self.selection.origin.row );
		
		updateRect = [self coordToRect: self.grid.selection.origin size: self.grid.selection.size];
		
		CGRectInset( updateRect, -3, -3 );
	
		[self setNeedsDisplayInRect: updateRect];
		
		return YES;
	}

	return NO;
}

- (void) touchesTwoMoved: (NSTimeInterval) when touches: (NSSet*) touches
{
	mTouchStart = when;

	if ( self.editMode ){
        [self trackSelection: [self touchesToArray: touches]];
    }else{
		CGPoint pt1 = [self arrayToPoint: mStartPoints atIndex: 0];
		CGPoint pt2 = [self arrayToPoint: mStartPoints atIndex: 1];
		
		float dx = pt1.x - pt2.x;
		float dy = pt1.y - pt2.y;
		
		float original = sqrt( dx * dx + dy * dy );
		
		CGPoint origCenter;
		
		if ( pt1.x < pt2.x ){
			origCenter.x = pt1.x + ( (pt2.x - pt1.x) / 2 );
		}else{
			origCenter.x = pt2.x + ( (pt1.x - pt2.x) / 2 );
		}

		if ( pt1.y < pt2.y ){
			origCenter.y = pt1.y + ( (pt2.y - pt1.y) / 2 );
		}else{
			origCenter.y = pt2.y + ( (pt1.y - pt2.y) / 2 );
		}
		
		NSMutableArray *points = [self touchesToArray: touches];
		
		pt1 = [self arrayToPoint: points atIndex: 0];
		pt2 = [self arrayToPoint: points atIndex: 1];

		dx = pt1.x - pt2.x;
		dy = pt1.y - pt2.y;
		
		float moved = sqrt( dx * dx + dy * dy );
		
		float newScale = mOriginalScale * ( moved / original );

		newScale = [self pinScale: newScale];

        NSLog( @"newScale=%f", newScale );
#if 0
		CGPoint newCenter;
		
		if ( pt1.x < pt2.x ){
			newCenter.x = pt1.x + ( (pt2.x - pt1.x) / 2 );
		}else{
			newCenter.x = pt2.x + ( (pt1.x - pt2.x) / 2 );
		}
		
		if ( pt1.y < pt2.y ){
			newCenter.y = pt1.y + ( (pt2.y - pt1.y) / 2 );
		}else{
			newCenter.y = pt2.y + ( (pt1.y - pt2.y) / 2 );
		}
		
		CGPoint delta;
		
		delta.x = newCenter.x - origCenter.x;
		delta.y = newCenter.y - origCenter.y;
#endif
		
		CGPoint lowerRightPixel;
		lowerRightPixel.x = self.bounds.size.width;
		lowerRightPixel.y = self.bounds.size.height;
		
		//GridCoord lowerRight = [self pointToCoord: lowerRightPixel];
		

		float xOff = ( ( lowerRightPixel.x / 2.0 ) / newScale ) - ( ( lowerRightPixel.x / 2.0 ) / mOriginalScale );
		float yOff = ( ( lowerRightPixel.y / 2.0 ) / newScale ) - ( ( lowerRightPixel.y / 2.0 ) / mOriginalScale );
		
		//printf( "%f %f\n", xOff, yOff );
	
		CGPoint newOrigin = mStartOrigin;
		newOrigin.x -= xOff;
		newOrigin.y -= yOff;
			
		self.scale = newScale;

		self.origin = [self pinOrigin: newOrigin];

		//printf( "* %f %f %f %f\n", self.origin.x, self.origin.y, newScale, mOriginalScale );

		[self setNeedsDisplay];
	}
	
	return;
}

- (CGPoint) arrayToPoint: (NSMutableArray*) points atIndex: (int) index
{
	NSValue *nsVal = [points objectAtIndex: index];
	
	CGPoint result;
	
	[nsVal getValue: &result];
	
	return result;
}

- (NSMutableArray*) touchesToArray: (NSSet*) touches;
{
	NSUInteger count = [touches count];

	NSMutableArray *result = [NSMutableArray arrayWithCapacity: count];
	
	for ( int i = 0; i < count; ++i ){
		
		CGPoint pt = [[[touches allObjects] objectAtIndex: i] locationInView: self];
		
		NSValue *ptVal = [NSValue valueWithBytes: &pt objCType: @encode( CGPoint ) ];
		
		[result addObject: ptVal];
	}

	return result;
}

#if 0
- (IBAction) toggleEdit: (id) sender
{
	if ( mEditMode ){
		mEditMode = FALSE;
		//[sender setTitle: @"Edit" forState: UIControlStateNormal];
	}else{
		mEditMode = TRUE;
		//[sender setTitle: @"Move" forState: UIControlStateNormal];
	}
	
	return;
}
#endif

- (void) setGeneration: (long) newGeneration
{
	long oldGen = mGeneration;
	
	mGeneration = newGeneration;
	
	if ( oldGen != mGeneration )
		[self setNeedsDisplay];
	
	return;
}

- (void) invalidateCell: (GridCoord) cell
{
	// We invalidate a square just a bit bigger than one cell,
	// otherwise the grid lines get drawn irregularly.
	
	CGRect invalRect;
	
	invalRect.origin = [self coordToPoint: cell];
	
	invalRect.size.width = self.scale;
	invalRect.size.height = self.scale;
	
	invalRect = CGRectInset( invalRect, -2.0, -2.0 );
	
	[self setNeedsDisplayInRect: invalRect];
	
	return;
}

- (void) drawRect: (CGRect) rect
{
    uint64_t drawStart = mach_absolute_time();

	GridCoord topLeft = [self pointToCoord: rect.origin];
	
	topLeft.col -= 1;
	
	if ( topLeft.col < self.origin.x )
		topLeft.col = self.origin.x;
	
	if ( topLeft.col < 0 )
		topLeft.col = 0;
	
	//if ( topLeft.col < 0 )
	//	topLeft.col = 0;
	
	topLeft.row -= 1;
	
	if ( topLeft.row < self.origin.y )
		topLeft.row = self.origin.y;
	
	if ( topLeft.row < 0 )
		topLeft.row = 0;
	
	//if ( topLeft.row < 0 )
	//	topLeft.row = 0;
	
	CGPoint brPt;
	
	brPt.x = rect.origin.x + rect.size.width;
	brPt.y = rect.origin.y + rect.size.height;

	GridCoord bottomRight = [self pointToCoord: brPt];

	bottomRight.row += 1;
	
	if ( bottomRight.row > self.grid.height )
		bottomRight.row = self.grid.height;
	
	bottomRight.col += 1;
	
	if ( bottomRight.col > self.grid.width )
		bottomRight.col = self.grid.width;

	CGRect eraseRect;
	
	eraseRect.origin = [self coordToPoint: topLeft];
	
	CGPoint erbr = [self coordToPoint: bottomRight];
	
	eraseRect.size.width = erbr.x + self.scale;
	eraseRect.size.height = erbr.y + self.scale;
	
	[[UIColor cyanColor] set];

	UIRectFill( eraseRect );
	
	[[UIColor blackColor] set];
	
	[self.grid lock];
	
	for( long y = topLeft.row; y < bottomRight.row; ++y ){

		GridCoord cell;

		cell.row = y;

		if ( self.editMode ){
			
			if ( self.scale >= 8 ){
				[self drawHorizontalGridLine: y from: self.origin.x to: bottomRight.col ];
			}
		}

		LifeRow currentRow = [self.grid getRow: y];

		CellRun living;
		
		living.col = topLeft.col;
		living.count = 0;

		GridCoord lineStart;
		
		lineStart.row = y;
		
		while ( living.col + living.count < bottomRight.col ){
		
			living = [self.grid nextRun: living row: currentRow];
			
			lineStart.col = living.col;

			[self drawLine: lineStart cellCount: living.count];
		}
		
		if ( self.editMode ){
		
			if ( self.scale >= 8 ){

				for ( long x = topLeft.col; x < bottomRight.col; ++x ){
		
					[self drawVerticalGridLine: x from: self.origin.y to: bottomRight.row];
				}
			}
		}
	}

	if ( self.editMode )
		[self drawSelection];

	[self.grid unlock];

    self.drawTime = mach_absolute_time() - drawStart;
    
	return;
}

- (void) drawHorizontalGridLine: (long) row from: (long) fromCol to: (long) toCol
{	
	CGRect bounds;
	
	bounds.origin.y = ( row - self.origin.y ) * self.scale;
	bounds.origin.x = ( fromCol - self.origin.x ) * self.scale;
	
	bounds.size.width = ( ( toCol - fromCol ) ) * self.scale;
	bounds.size.height = 1.0;
	
	UIRectFill( bounds );

	return;
}

- (void) drawVerticalGridLine: (long) col from: (long) fromRow to: (long) toRow
{
	CGRect bounds;
	
	bounds.origin.x = ( col - self.origin.x ) * self.scale;
	bounds.origin.y = ( fromRow - self.origin.y ) * self.scale;

	bounds.size.height = ( ( toRow - fromRow ) ) * self.scale;
	bounds.size.width = 1.0;
	
	UIRectFill( bounds );
	
	return;
}

- (CGPoint) coordToPoint: (GridCoord) cell
{
	CGPoint result;
	
	result.x = ( cell.col - self.origin.x ) * self.scale;
	result.y = ( cell.row - self.origin.y ) * self.scale;
	
	return result;
}

- (CGPoint) locationToPoint: (GridLocation) loc
{
    CGPoint result;
    
    result.x = ( loc.col - self.origin.x ) * self.scale;
    result.y = ( loc.row - self.origin.y ) * self.scale;
    
    return result;
}

- (CGRect) coordToRect: (GridCoord) theOrigin size: (GridCoord) theSize
{
	CGRect result;
	
	result.origin = [self coordToPoint: theOrigin];
	
	result.size.width = theSize.col * self.scale;
	result.size.height = theSize.row * self.scale;
	
	return result;
}

- (void) drawCell: (GridCoord) where
{
	CGRect bounds;
	
	bounds.origin = [self coordToPoint: where];
	
	bounds.size.width = self.scale;
	bounds.size.height = self.scale;
	
	UIRectFill( bounds );
	
	return;
}

- (void) drawLine: (GridCoord) where cellCount: (long) count
{
	CGRect bounds;
	
	bounds.origin = [self coordToPoint: where];
	
	bounds.size.width = self.scale * count;
	bounds.size.height = self.scale;
	
	UIRectFill( bounds );
	
	return;
}

- (void) restoreAffineMatrix
{	
	CGContextRef saveContext = UIGraphicsGetCurrentContext();
	
	CGAffineTransform saveTrans = CGContextGetCTM( saveContext );
		
	CGAffineTransform restore = CGAffineTransformInvert( saveTrans );
	
	CGContextConcatCTM( saveContext, restore );
	
	CGAffineTransform newTrans = CGAffineTransformMake( 1, 0, 0, -1, 0, self.frame.size.height );
	
	CGContextConcatCTM( saveContext, newTrans );
	
	return;
}

- (void) drawSelection
{
	if ( NULL == self.grid.selection )
		return;

	[[UIColor greenColor] set];
	
	CGRect eraseRect = [self coordToRect: self.grid.selection.origin size: self.grid.selection.size];
	
	UIRectFill( eraseRect );
	
	[[UIColor blackColor] set];

	LifeRow *cells = self.grid.selection.cells;
	
	GridCoord lineStart;
	
	for ( long row = 0; row < self.grid.selection.size.row; ++row ){
		
		lineStart.row = self.grid.selection.origin.row + row;
		
		LifeRow lifeRow = cells[ row ];
		
		CellRun living;
		
		living.col = 0;
		living.count = 0;
		
		while ( living.col + living.count < self.grid.selection.size.col ){
			
			living = NextRun( lifeRow, self.grid.selection.size.col, living );
			
			lineStart.col = living.col + self.grid.selection.origin.col;
			
			[self drawLine: lineStart cellCount: living.count];
		}
	}
	
	GridCoord coord;
	
	coord.row = self.grid.selection.origin.row;
	coord.col = self.grid.selection.origin.col;
	
    GridLocation loc;
    
    loc.row = coord.row;
    loc.col = coord.col;

	// Top Left
	[self drawSelectionCorner: coord];
	
	loc.col = self.grid.selection.origin.col + ( self.grid.selection.size.col / 2.0 ) - 0.5;
	
	// Top Middle
	[self drawSelectionEdge: loc];
	
	coord.col = self.grid.selection.origin.col + self.grid.selection.size.col - 1;
	
	// Top Right
	[self drawSelectionCorner: coord];
	
	loc.row = self.grid.selection.origin.row + ( self.grid.selection.size.row / 2.0 ) - 0.5;
	loc.col = coord.col;

	// Middle Right
	[self drawSelectionEdge: loc];
	
	coord.row = self.grid.selection.origin.row + self.grid.selection.size.row - 1;
	
	// Bottom Right
	[self drawSelectionCorner: coord];
	
	loc.col = self.grid.selection.origin.col + ( self.grid.selection.size.col / 2.0 ) - 0.5;
	loc.row = coord.row;

	// Bottom Middle
	[self drawSelectionEdge: loc];
	
	coord.col = self.grid.selection.origin.col;
	
	// Bottom Left
	[self drawSelectionCorner: coord];
	
	loc.row = self.grid.selection.origin.row + ( self.grid.selection.size.row / 2.0 ) - 0.5;
    loc.col = coord.col;

	// Middle Left
	[self drawSelectionEdge: loc];
	
	[self drawSelectionGrid];
	
	if ( mRotateCellCorner != -1 ){
		[self drawRotatedSelection];
	}
	
	if ( mReflectCellSide != -1 ){
		[self drawReflectedSelection];
	}
	
	return;
}

- (void) drawSelectionGrid
{
	[[UIColor yellowColor] set];
	
	long rowLim = self.grid.selection.origin.row + self.grid.selection.size.row;
	long toCol = self.grid.selection.origin.col + self.grid.selection.size.col;

	for ( long row = self.grid.selection.origin.row; row <= rowLim; ++row ){
	
		[self drawHorizontalGridLine: row from: self.grid.selection.origin.col to: toCol];
	}
	
	long colLim = self.grid.selection.origin.col + self.grid.selection.size.col;
	long toRow = self.grid.selection.origin.row + self.grid.selection.size.row;
	
	for ( long col = self.grid.selection.origin.col; col <= colLim; ++col ){
		
		[self drawVerticalGridLine: col from: self.grid.selection.origin.row to: toRow];
	}
	
	return;
}

- (void) drawRotatedSelection
{
	//printf( "%f\n", mRotationAngle );

	CGContextRef saveContext = UIGraphicsGetCurrentContext();
	
	CGAffineTransform saveTrans = CGContextGetCTM( saveContext );

	CGPoint translate;
	
	translate.x = self.scale * ( ( self.grid.selection.origin.col - self.origin.x )
								+ ( self.grid.selection.size.col / 2 ) );
	translate.y = self.scale * ( ( self.grid.selection.origin.row - self.origin.y )
								+ ( self.grid.selection.size.row / 2 ) );
	
	if ( self.grid.selection.size.col % 2 == 1 )
		translate.x += self.scale / 2.0;
	
	if ( self.grid.selection.size.row % 2 == 1 )
		translate.y += self.scale / 2.0;
	
	CGContextTranslateCTM( saveContext, translate.x, translate.y );
	
	CGContextRotateCTM( saveContext, -mRotationAngle );
	
	CGContextTranslateCTM( saveContext, -translate.x, -translate.y );

	[self drawSelectionGrid];
	
	CGAffineTransform rot = CGContextGetCTM( saveContext );
	
	CGAffineTransform restore = CGAffineTransformInvert( rot );
	
	CGContextConcatCTM( saveContext, restore );
	
	CGContextConcatCTM( saveContext, saveTrans );

	return;
}

- (void) drawReflectedSelection
{	
	CGContextRef saveContext = UIGraphicsGetCurrentContext();
	
	CGAffineTransform saveTrans = CGContextGetCTM( saveContext );
	
	CGPoint translate;
	
	translate.x = self.scale * ( ( self.grid.selection.origin.col - self.origin.x )
								+ ( self.grid.selection.size.col / 2 ) );
	translate.y = self.scale * ( ( self.grid.selection.origin.row - self.origin.y )
								+ ( self.grid.selection.size.row / 2 ) );
	
	if ( self.grid.selection.size.col % 2 == 1 )
		translate.x += self.scale / 2.0;
	
	if ( self.grid.selection.size.row % 2 == 1 )
		translate.y += self.scale / 2.0;
	
	CGContextTranslateCTM( saveContext, translate.x, translate.y );
	
	float xScale = 1.0;
	float yScale = 1.0;
	
	switch ( mReflectCellSide ){
		case 0:
		case 2:
			yScale =  mReflectionDistance / ( self.grid.selection.size.row * self.scale / 2 );
			break;
		
		case 1:
		case 3:
			xScale = mReflectionDistance / ( self.grid.selection.size.col * self.scale / 2 );
			break;
	}
	
	printf( "%f %f %f\n", mReflectionDistance, xScale, yScale );
	
	CGContextScaleCTM( saveContext, xScale, yScale );
	
	CGContextTranslateCTM( saveContext, -translate.x, -translate.y );
	
	[self drawSelectionGrid];
	
	CGAffineTransform scaleTM = CGContextGetCTM( saveContext );
	
	CGAffineTransform restore = CGAffineTransformInvert( scaleTM );
	
	CGContextConcatCTM( saveContext, restore );
	
	CGContextConcatCTM( saveContext, saveTrans );
	
	return;
}


- (void) drawSelectionCorner: (GridCoord) where
{
	CGRect circleRect;
	
	circleRect.origin = [self coordToPoint: where];
	
	circleRect.size.width = self.scale;
	circleRect.size.height = self.scale;

	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor( context, 1.0, 1.0, 0.0, 1.0 );
	
	CGContextBeginPath( context );
	
	CGContextAddEllipseInRect( context, circleRect );
	
	CGContextClosePath( context );

	CGContextFillPath( context );

	CGContextBeginPath( context );
	
	CGContextAddEllipseInRect( context, circleRect );
	
	CGContextClosePath( context );
	
	CGContextSetRGBStrokeColor( context, 0.0, 0.0, 0.0, 1.0 );
	
	CGContextSetLineWidth( context, 1.0 );

	CGContextStrokePath( context );

	return;
}

- (void) drawSelectionEdge: (GridLocation) where
{
    CGRect circleRect;
    
    circleRect.origin = [self locationToPoint: where];
    
    circleRect.size.width = self.scale;
    circleRect.size.height = self.scale;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor( context, 1.0, 1.0, 0.0, 1.0 );
    
    CGContextBeginPath( context );
    
    CGContextAddEllipseInRect( context, circleRect );
    
    CGContextClosePath( context );
    
    CGContextFillPath( context );
    
    CGContextBeginPath( context );
    
    CGContextAddEllipseInRect( context, circleRect );
    
    CGContextClosePath( context );
    
    CGContextSetRGBStrokeColor( context, 0.0, 0.0, 0.0, 1.0 );
    
    CGContextSetLineWidth( context, 1.0 );
    
    CGContextStrokePath( context );
    
    return;
}

- (float) distance: (CGPoint) from to: (CGPoint) theTo
{
	float dx = from.x - theTo.x;
	float dy = from.y - theTo.y;
	
	return sqrt( dx * dx + dy * dy );
}

@end
