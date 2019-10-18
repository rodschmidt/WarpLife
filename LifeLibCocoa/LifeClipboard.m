//
//  LifeClipboard.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/28/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "LifeClipboard.h"
#include "LifeLibCocoa/LifeSelection.h"

@implementation LifeClipboard

@synthesize size;
@synthesize cells;

- (id) initWithSelection: (LifeSelection*) selection
{
	if ( !(self = [self init] ) )
		return self;
	
	size = selection.size;
	
	cells = calloc( size.row, sizeof( LifeRow ) );
	
	if ( cells == NULL )
		return NULL;
	
	for ( long i = 0; i < size.row; ++i ){
		
		cells[ i ] = Allocate( size.col );
		
		if ( !cells[ i ] ){
			for ( long j = 0; j < i; ++j ){
				Free( &cells[ j ] );
			}
			free( cells );
			cells = NULL;
			
			return self;
		}
	}
	
	LifeRow *selCells = selection.cells;
	
	for ( long row = 0; row < self.size.row; ++row ){
		LifeRow clipRow = cells[ row ];
		LifeRow selRow = selCells[ row ];
		
		for ( long col = 0; col < size.col; ++col ){
			
			Set( clipRow, col, Get( selRow, col ) );
		}
	}
		
	return self;
}

@end
