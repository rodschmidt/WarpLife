//
//  LifeGrid.m
//  LifeOSX
//
//  Created by Michael D. Crawford on 12/3/09.
//  Copyright 2009 Dulcinea Technologies Corporation. All rights reserved.
//

#import "LifeGrid.h"

#import <unistd.h>
#import <assert.h>
#import <stdlib.h>
#import <string.h>
#import <mach/mach_time.h>
#include <sys/time.h>

#import "LifeLibCocoa/LifeSelection.h"
#import "LifeLibCocoa/LifeClipboard.h"
#import "LifeLibCocoa/LifeDisplay.h"

#import "iPhoneDevelopersCookbook/AccelerometerHelper.h"

@implementation LifeGrid

@synthesize clipboard;
@synthesize height;
@synthesize width;
@synthesize edited;
@synthesize speed;
@synthesize display;
@synthesize selection;
@synthesize shakeToRandomize;
@synthesize tickSum;
@synthesize tickAverage;
@synthesize tickSamples;
@synthesize gensPerRefresh;

- (id)init
{
    self = [super init];
    if (self) {
		
		mLock = [NSLock new];

		// [self setValue: [NSNumber numberWithInt: 0] forKey: @"generation"];

		mRunning = FALSE;

		selection = NULL;
		
		clipboard = NULL;
		
		display = NULL;
		
		mDisplayGrid = NULL;
		mScratchGrid = NULL;
		
		edited = NO;

		mAccelerometer = [[[AccelerometerHelper alloc] init] retain];
		
		mAccelerometer.delegate = self;
		
        [mAccelerometer start];
        
		shakeToRandomize = NO;

        speed = 1.0;

        self.gensPerRefresh = 0;
        
        genCounterLock = [[NSLock alloc] retain];
        
        [displayLink setFrameInterval: 1];

        runLoop = [NSRunLoop currentRunLoop];
        
        mSpeedCondition = [[NSCondition alloc] init];

        speedCalibrated = NO;
        maxGens = 0;
        throttleGens = 0;
        
        speed = 0.0f;
    }
    return self;
	
}

- (void) dealloc
{
    //[genCounterLock release];

    [mSpeedCondition release];

    [super dealloc];
    
    return;
}

- (void) tick
{
	[self lock];

	if ( self.edited ){
		[self copyGrid];
		self.edited = NO;
	}
	
	long maxRow = self.height - 1;
	
	long row;
	
	for( row = 1; row < maxRow; ++row ){
		
		LifeRow toRow = mScratchGrid[ 1 ];
		
		PropagateRow( toRow,
						mDisplayGrid[ row - 1 ], 
						mDisplayGrid[ row ],
						mDisplayGrid[ row + 1],
						self.width );
		
		if ( row != 1 ){
			LifeRow tmpRow = mDisplayGrid[ row - 1 ];
		
			mDisplayGrid[ row - 1 ] = mScratchGrid[ 0 ];
		
			mScratchGrid[ 0 ] = mScratchGrid[ 1 ];
			mScratchGrid[ 1 ] = tmpRow;
		}
	}

	[self unlock];

	return;
}

#if 0
- (long) generation
{
	return generation;
}

- (void) setGeneration: (long) newGeneration
{
	[self willChangeValueForKey: @"generation"];

	generation = newGeneration;
	
	[self didChangeValueForKey: @"generation"];
	
	return;
}

- (void) incrementGeneration
{
	[self setGeneration: 1 + [self generation]];
	
	return;
}
#endif

- (void) toggle: (GridCoord) where
{
	LifeWord oldState = Get( mDisplayGrid[ where.row ], where.col );
	
	Set( mDisplayGrid[ where.row ], where.col, oldState == 0 ? 1 : 0 );

	self.edited = YES;
	
	return;
}

- (void) setCell: (GridCoord) where state: (BOOL) alive
{
	Set( mDisplayGrid[ where.row ], where.col, alive ? 1 : 0 );
	
	return;
}

- (BOOL) state: (GridCoord) cell
{
	return Get( mDisplayGrid[ cell.row ], cell.col ) == 0 ? NO : YES;
}

- (LifeRow) getRow: (long) row
{
	assert( row >= 0 );
	assert( row < self.height );

	return mDisplayGrid[ row ];
}

- (LifeRow) getStartRow: (long) row
{
	assert( row >= 0 );
	assert( row < self.height );
	
	return mCopyGrid[ row ];
}

- (LifeRow*) cells
{
	return mDisplayGrid;
}

#if 0
- (void) setCells: (LifeRow*) cells width: (long) newWidth height: (long) newHeight
{
	GridCoord size;
	size.row = self.height;
	size.col = self.width;
	
	[self freeGrid: mDisplayGrid withSize: size];
	
	size.row = 2;
	
	[self freeGrid: mScratchGrid withSize: size];
	
	mDisplayGrid = cells;
	
	self.width = newWidth;
	self.height = newHeight;
	
	size.col = self.width;
	
	mScratchGrid = [self allocGrid: size];
	
	return;
}
#endif

- (void) merge: (LifeGrid*) grid where: (GridCoord) where
{
	if ( where.row < 0 )
		where.row = 0;
	
	if ( where.col < 0 )
		where.col = 0;
	
	long maxRow = [grid height];
	
	if ( where.row + maxRow > self.height )
		maxRow = self.height - where.row;
	
	long maxCol = [grid width];
	
	if ( where.col + maxCol > self.width )
		maxCol = self.width - where.col;

	long toRow = where.row;
	
	for ( long row = 0; row < maxRow; ++row, ++toRow ){
		LifeRow fromLifeRow = [grid getRow: row];
		LifeRow toLifeRow = [self getRow: toRow];
		
		long toCol = where.col;

		for ( long col = 0; col < maxCol; ++col ){
			Set( toLifeRow, toCol++, Get( fromLifeRow, col ) );
		}
		
	}
	
	return;
}

- (void) clearAll
{
	for ( long row = 0; row < self.height; ++row ){
		LifeRow lifeRow = mDisplayGrid[ row ];
		
		Clear( lifeRow, self.width );
		
		lifeRow = mCopyGrid[ row ];
		
		Clear( lifeRow, self.width );
	}
	
	return;
}

- (CellRun) nextRun: (CellRun) prevRun row: (LifeRow) currentRow
{
	assert( currentRow != NULL );
	assert( prevRun.col >= 0 );
	assert( prevRun.col + prevRun.count <= self.width );
	
	return NextRun( currentRow, self.width, prevRun );
}

- (void) lock
{
	[mLock lock];
	
	return;
}

- (void) unlock
{
	[mLock unlock];
	
	return;
}

- (BOOL) running
{
	return mRunning;
}

- (void) setRunning: (BOOL) isRunning
{
	[self willChangeValueForKey: @"mRunning"];
	
	mRunning = isRunning;
	
	[self didChangeValueForKey: @"mRunning"];
	
	return;
}

- (IBAction) start: (id) sender
{
	if ( mRunning )
		return;

	[self setRunning: TRUE];
	[NSThread detachNewThreadSelector: @selector( runThread: ) toTarget: [self class] withObject: self];
	
	return;
}

- (IBAction) stop: (id) sender
{
	[self setRunning: FALSE];

	return;
}

- (IBAction) step: (id) sender
{
	if ( !mRunning ){
		//[self cycle];
        
        [self tick];

        [self.display setNeedsDisplay];
    }
		
	return;
}

+ (void) runThread: (id) param
{	
	LifeGrid *field = (LifeGrid*)param;

	[field cycleContinuously];
	
	return;
}

- (void) displayTick: (CADisplayLink*) link
{
    // printf( "%ld %f\n", self.gensPerRefresh, self.speed );
    //printf( "%ld\n", self.gensPerRefresh );
    
    self.gensPerRefresh = 0;
    
    struct timeval timeOfDay;

    int err = gettimeofday( &timeOfDay, NULL );
    assert( 0 == err );
    
    mElapsedTime = timeOfDay.tv_sec + ( timeOfDay.tv_usec / 1000000.0 );

    if ( mDelayed ){
        mDelayed = NO;
        [mSpeedCondition signal];
    }

    [display setNeedsDisplay];
    
    return;
}

- (void) cycleContinuously
{
    mach_timebase_info_data_t timeBase;
    struct timeval timeOfDay;
    
    mach_timebase_info( &timeBase );
    
    uint64_t startTime = mach_absolute_time();

	long generation = 0;

    displayLink = [[CADisplayLink displayLinkWithTarget: self
                                               selector: @selector( displayTick: )] retain];
    [displayLink addToRunLoop: runLoop forMode: NSDefaultRunLoopMode];

    mDelayed = NO;
    mElapsedTime = 0.0f;
 
    int err = gettimeofday( &timeOfDay, NULL );
    assert( 0 == err );
    
    mElapsedTime = timeOfDay.tv_sec + ( timeOfDay.tv_usec / 1000000.0 );
   
    while ( mRunning ){
        
        int err = gettimeofday( &timeOfDay, NULL );
        assert( 0 == err );
    
        double foo = ((double)timeOfDay.tv_sec) + ( (double)timeOfDay.tv_usec / 1000000.0 );
    
        double bar = foo - mElapsedTime;
    
        BOOL locked = NO;
        
        if ( bar > ( speed / 60.0f ) ){
            locked = YES;
            [mSpeedCondition lock];
            mDelayed = YES;
            while ( mDelayed ){
                [mSpeedCondition wait];
            }
        }
        
        ++generation;
        ++( self.gensPerRefresh );
        
        // [self cycle];
        [self tick];
        
        if ( locked )
            [mSpeedCondition unlock];

    }
    
    [displayLink invalidate];

    uint64_t endTime = mach_absolute_time();
    uint64_t elapsed = endTime - startTime;
    
    double seconds = (( (double)( elapsed * timeBase.numer ) ) / timeBase.denom ) / 1.0e9;
    
    printf( "speed: %f\n", speed);
	printf( "gen/sec: %f\n", ( (float)generation ) / seconds );

	return;
}

- (void) copyGrid
{
	for ( long row = 0; row < self.height; ++row ){
		LifeRow fromRow = mDisplayGrid[ row ];
		LifeRow toRow = mCopyGrid[ row ];
		
		for ( long col = 0; col < self.width; ++col ){
			Set( toRow, col, Get( fromRow, col ) );
		}
	}
	
	return;
}

- (BOOL) resize: (long) newWidth height: (long) newHeight
{
	if ( newWidth == self.width && newHeight == self.height )
		return YES;

	GridCoord gridSize;
	gridSize.row = newHeight;
	gridSize.col = newWidth;
	
	LifeRow *newDisplayGrid = [self allocGrid: gridSize];
	if ( NULL == newDisplayGrid )
		return NO;

	LifeRow *newCopyGrid = [self allocGrid: gridSize];
	if ( NULL == newCopyGrid ){
		[self freeGrid: newDisplayGrid withSize: gridSize];
		return NO;
	}
	
	GridCoord scratchSize;
	
	scratchSize.row = 2;
	scratchSize.col = newWidth;
	
	LifeRow *newScratchGrid = [self allocGrid: gridSize];
	
	if ( NULL == newScratchGrid ){
		[self freeGrid: newDisplayGrid withSize: gridSize];
		[self freeGrid: newCopyGrid withSize: gridSize];
		return NO;
	}
	
	long toRow;
	long fromRow;
	long maxRow;
	
	if ( newHeight >= self.height ){
		toRow = ( newHeight - self.height ) / 2;
		fromRow = 0;
		maxRow = self.height;
	}else{
		toRow = 0;
		fromRow = ( self.height - newHeight ) / 2;
		maxRow = fromRow + newHeight;
	}
	
	assert( toRow >= 0 );
	assert( maxRow <= self.height );
	
	long toCol;
	long fromCol;
	long maxCol;
	
	if ( newWidth >= self.width ){
		toCol = ( newWidth - self.width ) / 2;
		fromCol = 0;
		maxCol = self.width;
	}else{
		toCol = 0;
		fromCol = ( self.width - newWidth ) / 2;
		maxCol = fromCol + newWidth;
	}
	
	assert( toCol >= 0 );
	assert( maxCol <= self.width );

	for ( long row = fromRow; row < maxRow; ++row, ++toRow ){
		LifeRow fromLifeRow = mDisplayGrid[ row ];
		LifeRow toLifeRow = newDisplayGrid[ toRow ];
		
		LifeRow fromCopyRow = mCopyGrid[ row ];
		LifeRow toCopyRow = newCopyGrid[ toRow ];
		
		long toRowCol = toCol;
		
		for ( long col = fromCol; col < maxCol; ++col, ++toRowCol ){
			Set( toLifeRow, toRowCol, Get( fromLifeRow, col ) );
			Set( toCopyRow, toRowCol, Get( fromCopyRow, col ) );
		}
	}
	
	gridSize.col = self.width;
	gridSize.row = self.height;
	
	[self freeGrid: mDisplayGrid withSize: gridSize];
	[self freeGrid: mCopyGrid withSize: gridSize];
	
	gridSize.row = 2;
	
	[self freeGrid: mScratchGrid withSize: gridSize];
	
	mDisplayGrid = newDisplayGrid;
	mCopyGrid = newCopyGrid;
	mScratchGrid = newScratchGrid;
	
	self.width = newWidth;
	self.height = newHeight;
	
	return YES;
}

- (BOOL) initGrid;
{
	GridCoord gridSize;
	gridSize.row = self.height;
	gridSize.col = self.width;
    
NSLog( @"row=%ld col=%ld", gridSize.row, gridSize.col );
	
	// How to report failure?
	
	mDisplayGrid = [self allocGrid: gridSize ];
	if ( NULL == mDisplayGrid )
		return NO;
	
	mCopyGrid = [self allocGrid: gridSize];
	if ( NULL == mCopyGrid ){
		[self freeGrid: mDisplayGrid withSize: gridSize];
		return NO;
	}
	
	GridCoord nextSize;
	nextSize.row = 2;
	nextSize.col = self.width;
	
	mScratchGrid = [self allocGrid: nextSize ];
	if ( NULL == mScratchGrid ){
		[self freeGrid: mDisplayGrid withSize: gridSize];
		[self freeGrid: mCopyGrid withSize: gridSize];
		
		return NO;
	}

	return YES;
}

- (LifeRow*) allocGrid: (GridCoord) size;
{
	LifeRow *grid;
	
	grid = calloc( size.row, sizeof( LifeRow ) );       // TODO: malloc?
		
	if ( NULL == grid ) return nil;

#if 1

    unsigned long words = Words( size.col );
    
    LifeRow buf = (LifeRow)calloc( size.row * words, sizeof( LifeWord ) );
    
    if ( NULL == buf ) free( buf );
    
    for ( long i = 0; i < size.row; ++i ){
        grid[ i ] = buf + (words * i );
    }

#else

	for ( long i = 0; i < size.row; ++i ){
		
		grid[ i ] = Allocate( size.col );
		
		if ( NULL == grid[ i ] ){
			[self freeGrid: grid withSize: size];
			return NULL;
		}
	}

#endif
	
	return grid;
}

- (void) freeGrid: (LifeRow*) grid withSize: (GridCoord) size
{
	if ( NULL != grid ){
#if 0   // We no longer allocate the individual rows, rather we subdivide
        // one big buffer

		for( long i = 0; i < size.row; ++i ){
			if ( NULL != grid[ i ] )
				Free( &grid[ i ] );
		}
#endif
		free( grid );
	}

	return;
}

- (BOOL) inLivingCell: (GridCoord) where
{	
	if ( where.col >= self.width || where.row >= self.height )
		return FALSE;
	
	return Get( mDisplayGrid[ where.row ], where.col );
}

- (IBAction) adjustSpeed: (id) sender
{
	speed = ((UISlider*)sender).value;
	
    printf( "%f\n", speed );

    return;
}

#if 0
- (long) height
{
	return mHeight;
}

- (void) setHeight: (long) height
{
	mHeight = height;
	
	return;
}

- (long) width
{
	return mWidth;
}

- (void) setWidth: (long) width
{
	mWidth = width;
	
	return;
}
#endif

- (LifeRow*) getDisplayGrid
{
	return mDisplayGrid;
}

- (void) randomize: (float) probability
{
	int iProb = probability * 32767;
	
	for ( long j = 0; j < self.height; j++ ){
	
		LifeRow row = mDisplayGrid[ j ];
		
		for ( long i = 0; i < self.width; i++ ){
		
			if ( random() % 32767 < iProb ){
				
				if ( Get( row, i ) == 0 ){
					Set( row, i, 1 );
				}else{
					Set( row, i, 0 );
				}
			}
				
		}
	}
	return;
}

- (void) cut
{
    LifeClipboard *clip = [[LifeClipboard alloc] initWithSelection: self.selection];
	
    // [self.selection release];
    
	self.selection = nil;
    
    self.clipboard = clip;
    
    [clip release];

	[display setNeedsDisplay];
	
	return;
}

- (void) copyToClipboard
{
	LifeClipboard *clip = [[LifeClipboard alloc] initWithSelection: self.selection];

    self.clipboard = clip;
    
    [clip release];

	return;
}

- (void) paste
{
	if ( self.selection )
		[self.selection dropCells: self];

	LifeSelection *sel = [[LifeSelection alloc] initWithClipboard: self.clipboard];
	
    self.selection = sel;
    
    [sel release];

	GridCoord origin = [display center];
	
	origin.col = origin.col - ( self.selection.size.col / 2 );
	origin.row = origin.row - ( self.selection.size.row / 2 );
	
	self.selection.origin = origin;
	
	[display setNeedsDisplay];
	
	return;
}

- (void) clearSelection
{
	GridCoord origin = self.selection.origin;
	GridCoord size = self.selection.size;
	
	long rowLim = origin.row + size.row;
	
	if ( rowLim > self.height )
		rowLim = self.height;
	
	long rowStart = origin.row;
	if ( rowStart < 0 )
		rowStart = 0;
	
	long colLim = origin.col + size.col;
	
	if ( colLim > self.width )
		colLim = self.width;
	
	long colStart = origin.col;
	if ( colStart < 0 )
		colStart = 0;
	
	for ( long row = rowStart; row < rowLim; ++row ){
	
		LifeRow cellRow = mDisplayGrid[ row ];
		
		for ( long col = colStart; col < colLim; ++col ){
			Set( cellRow, col, 0 );
		}
		
	}
	
	self.selection = NULL;
	
	[display setNeedsDisplay];
	
	return;
}

#if 0
- (LifeSelection*) selection
{
    return selection;
}

- (void) setSelection: (LifeSelection*) newSelection
{
    self->selection = newSelection;

    return;
}
#endif

- (void) startBoundingBox: (GridCoord*) originPtr size: (GridCoord*) sizePtr
{
	[self boundCommon: mCopyGrid origin: originPtr size: sizePtr];
	
	return;
}

- (void) boundingBox: (GridCoord*) originPtr size: (GridCoord*) sizePtr
{
	[self boundCommon: mDisplayGrid origin: originPtr size: sizePtr];
	
	return;
}

- (void) boundCommon: (LifeRow*) grid origin: (GridCoord*) originPtr size: (GridCoord*) sizePtr
{
	originPtr->row = -1;
	originPtr->col = -1;
	sizePtr->row = 0;
	sizePtr->col = 0;
	
	for ( long row = 0; row < self.height; ++row ){
		LifeRow lifeRow = grid[ row ];
		
		if ( HasLivingCells( lifeRow, self.width ) ){
			originPtr->row = row;
			break;
		}
	}
	
	if ( originPtr->row != -1 ){

		for ( long row = self.height - 1; row >= originPtr->row; --row ){
			LifeRow lifeRow = grid[ row ];
			
			if ( HasLivingCells( lifeRow, self.width ) ){
				sizePtr->row = 1 + row - originPtr->row;
				break;
			}
		}
		
		long rowLim = originPtr->row + sizePtr->row;
		
		long minCol = self.width;
		
		long maxCol = -1;
		
		for ( long row = originPtr->row; row < rowLim; ++row ){
			
			LifeRow lifeRow = grid[ row ];
			
			long leftCol = LeftMostCell( lifeRow, self.width );
			long rightCol = RightMostCell( lifeRow, self.width );
			
			if ( leftCol != -1 && leftCol < minCol )
				minCol = leftCol;
			
			if ( rightCol != -1 && rightCol > maxCol )
				maxCol = rightCol;
		}
		
		originPtr->col = minCol;
		sizePtr->col = 1 + maxCol - minCol;
			
	}
	
	return;
}

- (void) shake
{
	if ( !self.shakeToRandomize )
		return;
	
	[self randomize: 0.05];
	
	[mAccelerometer reset];
	
	[self.display setNeedsDisplay];
	
	return;
}
@end
