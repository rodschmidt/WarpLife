//
//  LifeSelection.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/22/10.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#import "LifeSelection.h"

#import "LifeLibCocoa/LifeGrid.h"
#import "LifeLibCocoa/LifeRow.h"
#import "LifeLibCocoa/LifeClipboard.h"

@implementation LifeSelection

@synthesize origin;
@synthesize size;
@synthesize cells;
				  
- (LifeSelection*) init: (GridCoord) theOrigin size: (GridCoord) theSize
{
	if ( (self = [super init] ) ){

		origin = theOrigin;
		size = theSize;
	
		if (![self allocateCells] )
			return NULL;
	}
	
	return self;
}

- (id) initWithClipboard: (LifeClipboard*) clipboard;
{
	GridCoord theOrigin;
	theOrigin.row = 0;
	theOrigin.col = 0;
	
	if ( !(self = [self init: theOrigin size: clipboard.size] ) )
		return self;
		
	LifeRow *clipCells = clipboard.cells;
	
	for ( long row = 0; row < self.size.row; ++row ){
		LifeRow selRow = cells[ row ];
		LifeRow clipRow = clipCells[ row ];
		
		for ( long col = 0; col < self.size.col; ++col ){
			
			Set( selRow, col, Get( clipRow, col ) );
		}
	}
	
	return self;
}

- (void) dealloc
{
	if ( cells != NULL){
	
		[self freeCells: &cells rows: self.size.row];
	}
	
	[super dealloc];
	
	return;
}

- (BOOL) allocateCells
{
	cells = calloc( sizeof( LifeRow ), self.size.row );
	
	if ( !cells )
		return NO;

	for ( long row = 0; row < self.size.row; ++row ){
		cells[ row ] = Allocate( self.size.col );
		
		if ( NULL == cells[ row ] ){

			[self freeCells: &cells rows: self.size.row];

			return NO;
		}
	}

	return YES;
}

- (BOOL) grabCells: (LifeGrid*) grid
{
#if 0
	fprintf( stderr, "- %d %d %d %d\n", 
				self.origin.col, 
				self.origin.row, 
				self.size.col, 
				self.size.row );
#endif

	if ( ![self allocateCells] )
		return NO;
	
	long rowLim = self.origin.row + self.size.row;
	
	long selRow = 0;
	
	LifeRow *displayGrid = [grid getDisplayGrid];
	
	for ( long row = self.origin.row; row < rowLim; ++row, ++selRow ){
		
		LifeRow lifeRow = displayGrid[ row ];
		
		long colLim = self.origin.col + self.size.col;
		
		long selCol = 0;
		
		for ( long col = self.origin.col; col < colLim; ++col, ++selCol ){
			
			if ( Get( lifeRow, col ) ){
				Set( cells[ selRow ], selCol, 1 );
			}else{
				Set( cells[ selRow ], selCol, 0 );
			}
			Set( lifeRow, col, 0 );
		}
		
	}
		
	return YES;
}

- (void) dropCells: (LifeGrid*) grid
{	
#if 0
	fprintf( stderr, "- %d %d %d %d\n", 
			self.origin.col, 
			self.origin.row, 
			self.size.col, 
			self.size.row );
#endif
	
	long gridRow = self.origin.row;
	
	if ( gridRow < 0 )
		gridRow = 0;
	
	long maxRow = self.size.row;
	
	if ( maxRow + self.origin.row >= [grid height] )
		maxRow -= self.origin.row - [grid height];
	
	long maxCol = self.size.col;
	
	if ( maxCol + self.origin.col >= [grid width] )
		maxRow -= self.origin.col - [grid width];
	
	LifeRow *displayGrid = [grid getDisplayGrid];
	
	for ( long row = 0; row < maxRow; ++row, ++gridRow ){
		
		LifeRow lifeRow = displayGrid[ gridRow ];
				
		long gridCol = self.origin.col;
		
		if ( gridCol < 0 )
			gridCol = 0;

		for ( long col = 0; col < maxCol; ++col, ++gridCol ){
			
			if ( Get( cells[ row ], col ) ){
				Set( lifeRow, gridCol, 1 );
			}else{
				Set( lifeRow, gridCol, 0 );
			}
		}
		
	}
	
	[self freeCells: &cells rows: self.size.row];
		
	grid.edited = YES;

	return;
}

- (BOOL) inside: (GridCoord) where
{	
	if ( ( where.row >= self.origin.row && where.row <= self.origin.row + self.size.row )
		&& ( where.col >= self.origin.col && where.col <= self.origin.col + self.size.col ) ){
		
		return YES;
	}
	
	return NO;
}

- (BOOL) insideLocation: (GridLocation) where
{
    if ( ( where.row >= self.origin.row && where.row <= self.origin.row + self.size.row )
        && ( where.col >= self.origin.col && where.col <= self.origin.col + self.size.col ) ){
        
        return YES;
    }
    
    return NO;
}

- (int) inCorner: (GridCoord) cell
{	
	if ( cell.row == self.origin.row && cell.col == self.origin.col )
		return 0;
	
	long right = self.origin.col + self.size.col - 1;
	
	if ( cell.row == self.origin.row && cell.col == right )
		return 1;
	
	long bottom = self.origin.row + self.size.row - 1;
	
	if ( cell.row == bottom && cell.col == right )
		return 2;
	
	if ( cell.row == bottom && cell.col == self.origin.col )
		return 3;

	return -1;
}

- (int) inSideHandleLocation: (GridLocation) loc
{
    float halfCol = self.origin.col + ( self.size.col / 2.0 );
    float halfRow = self.origin.row + ( self.size.row / 2.0 );
    long right = self.origin.col + self.size.col - 1;
    long bottom = self.origin.row + self.size.row - 1;
    
    if ( (( loc.row <= self.origin.row + 0.5 ) && ( loc.row >= self.origin.row - 0.5 ))
        && (( loc.col <= halfCol + 0.5 ) && ( loc.col >= halfCol - 0.5 )))
        return 0;
    
    if ((( loc.row <= halfRow + 0.5 ) && ( loc.row >= halfRow - 0.5 ))
        && (( loc.col <= right + 0.5 ) && ( loc.col >= right - 0.5 )) )
        return 1;
    
    if ( ((loc.row <= bottom + 0.5) && (loc.row >= bottom - 0.5))
        && (( loc.col <= halfCol + 0.5 ) && ( loc.col >= halfCol - 0.5 )))
        return 2;
    
    if ( (( loc.row <= halfRow + 0.5 ) && ( loc.row >= halfRow - 0.5 ))
        && ((loc.col <= self.origin.col + 0.5) && (loc.col >= self.origin.col - 0.5)) )
        return 3;
    
    return -1;
}

- (int) inSideHandle: (GridCoord) cell
{
	long halfCol = self.origin.col + ( self.size.col / 2 );
	long halfRow = self.origin.row + ( self.size.row / 2 );
	long right = self.origin.col + self.size.col - 1;
	long bottom = self.origin.row + self.size.row - 1;
	
	if ( cell.row == self.origin.row && cell.col == halfCol )
		return 0;
	
	if ( cell.row == halfRow & cell.col == right )
		return 1;
	
	if ( cell.row == bottom & cell.col == halfCol )
		return 2;
	
	if ( cell.row == halfRow && cell.col == self.origin.col )
		return 3;

	return -1;
}

- (void) rotateRight
{
	LifeRow *cellSav = cells;
	GridCoord originSav = self.origin;
	GridCoord sizeSav = self.size;
	
	GridCoord center;
	center.col = originSav.col + ( sizeSav.col / 2 );
	center.row = originSav.row + ( sizeSav.row / 2 );
	
	GridCoord newSize;
	newSize.col = sizeSav.row;
	newSize.row = sizeSav.col;

	GridCoord newOrigin;
	newOrigin.col = center.col - ( newSize.col / 2 );
	newOrigin.row = center.row - ( newSize.row / 2 );
	
	self.size = newSize;
	self.origin = newOrigin;

	if ( ![self allocateCells] )
		return;
	
	// A B C
	// D E F
	// G H I
	// J K L
	
	// J G D A
	// K H E B
	// L I F C
		
	for ( long row = 0; row < self.size.row; ++row ){
	
		LifeRow newRow = cells[ row ];
		
		long fromCol = sizeSav.row - 1;
		
		for ( long col = 0; col < self.size.col; ++col, --fromCol ){
			Set( newRow, col, Get( cellSav[ fromCol ], row ) );
		}
	}
	
	[self freeCells: &cellSav rows: sizeSav.row];
	
	return;
}

- (void) rotateLeft
{
	LifeRow *cellSav = cells;
	GridCoord originSav = self.origin;
	GridCoord sizeSav = self.size;
	
	GridCoord center;
	center.col = originSav.col + ( sizeSav.col / 2 );
	center.row = originSav.row + ( sizeSav.row / 2 );
	
	GridCoord newSize;
	newSize.col = sizeSav.row;
	newSize.row = sizeSav.col;
	
	GridCoord newOrigin;
	newOrigin.col = center.col - ( newSize.col / 2 );
	newOrigin.row = center.row - ( newSize.row / 2 );
	
	self.size = newSize;
	self.origin = newOrigin;
	
	if ( ![self allocateCells] )
		return;

	// A B C
	// D E F
	// G H I
	// J K L
	
	// C F I L
	// B E H K
	// A D G J
		
	long fromRow = sizeSav.col - 1;

	for ( long row = 0; row < self.size.row; ++row, --fromRow ){
		
		LifeRow newRow = cells[ row ];
		
		for ( long col = 0; col < self.size.col; ++col ){
			Set( newRow, col, Get( cellSav[ col ], fromRow ) );
		}
	}
	
	[self freeCells: &cellSav rows: sizeSav.row];
	
	return;
}

- (void) reflectVertical
{
	// A B
	// C D
	//
	// C D
	// A B
	
	BOOL buf;
	
	long bottomRow = self.size.row - 1;
	long topRow = 0;
	
	while ( topRow < bottomRow ){
	
		LifeRow topLifeRow = cells[ topRow ];
		LifeRow bottomLifeRow = cells[ bottomRow ];
		
		for ( long col = 0; col < self.size.col; ++col ){
			buf = Get( topLifeRow, col );
			Set( topLifeRow, col, Get( bottomLifeRow, col ) );
			Set( bottomLifeRow, col, buf );
		}
		
		++topRow;
		--bottomRow;
	}
	
	return;
}

- (void) reflectHorizontal
{
	// A B
	// C D
	//
	// B A
	// D C
	
	for ( long row = 0; row < self.size.row; ++row ){
		
		BOOL buf;
		
		long rightCol = self.size.col - 1;
		long leftCol = 0;
		
		LifeRow lifeRow = cells[ row ];
		while ( leftCol < rightCol ){
			
			buf = Get( lifeRow, leftCol );
			Set( lifeRow, leftCol, Get( lifeRow, rightCol ) );
			Set( lifeRow, rightCol, buf );
				
			++leftCol;
			--rightCol;
		}
	}
	
	return;
}

- (void) freeCells: (LifeRow**) inOutCells rows: (long) theRows
{
	for( long row = 0; row < theRows; ++row ){
		Free( &((*inOutCells)[ row ]) );
	}
	
	free( *inOutCells );
	
	*inOutCells = NULL;
	
	return;
}


@end
