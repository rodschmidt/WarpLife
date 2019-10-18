//
//  LifeByte.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/1/09.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//

#include "CellRun.h"

typedef unsigned long LifeWord;

typedef LifeWord * LifeRow;

enum{
	kNumAdjacentRows = 3
};

typedef LifeRow LifeRowArray[ kNumAdjacentRows ] ;

LifeRow Allocate( long columns );

void Free( LifeRow *rowPtr );

LifeWord Get( LifeRow row, long col );

void Set( LifeRow row, long col, LifeWord val );

void TurnOn( LifeRow row, long col );

void TurnOff( LifeRow row, long col );

int Count2( LifeRow row, long col );

int Count3( LifeRow row, long col );

CellRun NextRun( LifeRow row, long rowLen, CellRun prevRun );

// long FindBit( LifeRow row, long rowLen, long start, BOOL set );
long FindBit( LifeRow row, long rowLen, long start, int set );

int NeighborLookup( LifeRow upperRow, LifeRow thisRow, LifeRow lowerRow, long col );

//void PropagateRow( LifeRow dest, LifeRowArray source, long columns );
void PropagateRow( LifeRow dest, 
					LifeRow upperRow, 
					LifeRow currentRow, 
					LifeRow lowerRow, 
				  long columns );

void Clear( LifeRow row, long columns );

unsigned long Words( long columns );

// BOOL HasLivingCells( LifeRow row, long columns );
int HasLivingCells( LifeRow row, long columns );
long LeftMostCell( LifeRow row, long columns );
long RightMostCell( LifeRow row, long columns );

