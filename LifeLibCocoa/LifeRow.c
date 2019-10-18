//
//  LifeByte.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/1/09.
//  Copyright 2010 Dulcinea Technologies Corporation. All rights reserved.
//


#import "LifeRow.h"

#include <assert.h>
#include <limits.h>
#include <stdlib.h>

#include "NeighborLut.h"

// static int CountCommon( LifeRow, long col, unsigned int bitmask );

enum{
	kWordBits = sizeof( LifeWord ) * CHAR_BIT,
	kWordShift = 5,
	kWordMask = 0x0000001f
};

#if 0
static int sLive[ 8 ] = {
	0,	// 0: 000
	1,	// 1: 001
	1,	// 2: 010
	2,	// 3: 011
	1,	// 4: 100
	2,  // 5: 101
	2,  // 6: 110
	3   // 7: 111
};
#endif

unsigned long Words( long columns )
{
	unsigned long words = columns >> kWordShift;
	
	if ( ( columns & kWordMask ) != 0 )
		++words;

	return words;
}

LifeRow Allocate( long columns )
{
	long words = Words( columns );
	
	return calloc( words, sizeof( LifeWord ) );
}

void Free( LifeRow *rowPtr )
{
	assert( NULL != rowPtr );
	assert( NULL != *rowPtr );
	
	free( *rowPtr );
	
	*rowPtr = NULL;
	
	return;
}

LifeWord Get( LifeRow row, long col )
{
	if ( row[ col >> kWordShift ] & ( 1 << ( col & kWordMask ) ) )
		return 1;
	
	return 0;
}

void Set( LifeRow row, long col, LifeWord val )
{
	LifeWord *ptr = row + ( col >> kWordShift );
	
	LifeWord word = *ptr;

	unsigned int bit = 1 << ( col & kWordMask );
	
	if ( !val ){
		word &= ~bit;
	}else{
		word |= bit;
	}
	
	*ptr = word;
	
	return;
}

#if 0
void TurnOn( LifeRow row, long col )
{	
	row[ col >> kWordShift ] |= 1 << ( col & kWordMask );

	return;
}
#endif

#if 0
void TurnOff( LifeRow row, long col )
{	
	row[ col >> kWordShift ] &= ~( 1 << ( col & kWordMask ) );
	
	return;
}
#endif

#if 0
int Count2( LifeRow row, long col )
{
	return CountCommon( row, col, 0x00000005 );		// 101
}
#endif

#if 0
int Count3( LifeRow row, long col )
{
	return CountCommon( row, col, 0x00000007 );		// 111
}
#endif

#if 0
int CountCommon( LifeRow row, long col, unsigned int bitmask )
{
	unsigned int word = row[ col >> kWordShift ];
	
	int shift = col & kWordMask;
	
	shift--;
	
	int neighbors = 0;
	
	if ( shift == -1 ){
		
		unsigned int wordLeft = row[ ( col - 1 ) >> kWordShift ];
		
		if ( wordLeft & 0x80000000 )
			++neighbors;
		
		shift = 0;
		bitmask >>= 1;
	}else if ( shift == 30 ){
		
		unsigned int wordRight = row[ ( col + 1 ) >> kWordShift ];
		
		if ( wordRight & 0x00000001 )
			++neighbors;
	}
	
	unsigned int index = word >> shift;
	
	index = index & bitmask;
	
	neighbors += sLive[ index ];
	
	return neighbors;
}
#endif

#if 1
// void PropagateRow( LifeRow dest, LifeRowArray source, long columns )
void PropagateRow( LifeRow dest, LifeRow upperRow, LifeRow currentRow, LifeRow lowerRow, long columns )
{
	long word = Words( columns );
	
	--word;
	
	int middleBits;
	
	if ( ( columns & kWordMask ) != 0 ){
		
		middleBits = ( columns & kWordMask ) - 1;
	}else{
		middleBits = 30;
	}

	int skipIt = 1;
		
	while ( word >= 0 ){

#if 0
		LifeWord up = source[ 0 ][ word ];
		LifeWord here = source[ 1 ][ word ];
		LifeWord down = source[ 2 ][ word ];
#endif
		LifeWord up = upperRow[ word ];
		LifeWord here = currentRow[ word ];
		LifeWord down = lowerRow[ word ];
		
		LifeWord out = 0;
		
		unsigned long index = 0;
		
		if ( word != 0 ){

			//unsigned long wordLeft = source[ 0 ][ word - 1 ];
			unsigned long wordLeft = upperRow[ word - 1 ];
			
			if ( wordLeft & 0x80000000 ){
				index = 0x00000001;	// 0 0000 0001
			}			
			
			index |= ( up & 3 ) << 1;
			
			//wordLeft = source[ 1 ][ word - 1 ];
			wordLeft = currentRow[ word - 1 ];
			
			if ( wordLeft & 0x80000000 ){
				index |= 0x00000008;	// 0 0000 1000
			}			
			
			index |= ( here & 3 ) << 4;
			
			//wordLeft = source[ 2 ][ word - 1 ];
			wordLeft = lowerRow[ word - 1 ];
			
			if ( wordLeft & 0x80000000 ){
				index |= 0x00000040;	// 0 0100 0000
			}			
			
			index |= ( down & 3 ) << 7;
			
			assert( index < 512 );

			if ( gNeighborLut[ index ] != 0 ){
				
				out = 1;
			}
			

		}
		
		if ( up != 0 || here != 0 || down != 0 ){
			
		unsigned long outBit = 2;
		
		for ( int shift = 0; shift < middleBits; ++shift ){
	
#if 0
			index = up >> shift;
			
			unsigned long index2 = here >> shift;
			
			unsigned long index3 = down >> shift;
			
			index &= 7;
			
			index2 &= 7;
			
			index3 &= 7;
			
			index2 <<= 3;
			
			index3 <<= 6;
			
			index |= index2;
			
			index |= index3;
#endif

			index = ( up >> shift ) & 7;
						
			unsigned long index2 = ( ( here >> shift ) & 7 ) << 3;	// 0 0011 1000
						
			unsigned long index3 = ( ( down >> shift ) & 7 ) << 6;	// 1 1100 0000
			
			index |= index2;
			index |= index3;
			
			assert( index < 512 );

			if ( gNeighborLut[ index ] != 0 ){
				
				out |= outBit;
			}
			
			outBit <<= 1;
		}
		}
		
		middleBits = 30;
		
		if ( !skipIt ){
						
			index = 0;

			//unsigned long wordRight = source[ 0 ][ word + 1 ];
			unsigned long wordRight = upperRow[ word + 1 ];
			
			if ( wordRight & 0x00000001 ){
				index = 0x00000004;	// 0 0000 0100
			}			
			
			index |= ( up >> 30 ) & 3;
			
			//wordRight = source[ 1 ][ word + 1 ];
			wordRight = currentRow[ word + 1 ];
			
			if ( wordRight & 0x00000001 ){
				index |= 0x00000020;	// 0 0010 0000
			}			
			
			index |= ( here >> 27 ) & 0x18;	// 0 0001 1000
			
			//wordRight = source[ 2 ][ word + 1 ];
			wordRight = lowerRow[ word + 1 ];
			
			if ( wordRight & 0x00000001 ){
				index |= 0x00000100;	// 1 0000 0000
			}			
			
			index |= ( down >> 24 ) & 0xc0;	// 0 1100 0000
			
			assert( index < 512 );
			
			if ( gNeighborLut[ index ] != 0 ){
				
				out |= 0x80000000;
			}
		}
		
		skipIt = 0;

		dest[ word ] = out;

		--word;
	}
	
}
#endif

#if 0
void PropagateRow( LifeRow dest, LifeRowArray source, long columns )
{
	long maxCol = columns - 1;
	
	for ( long col = 1; col < maxCol; ++col ){
	
		unsigned long index = 0;
		
		int threeShift = 0;
		
		int shift = col & kWordMask;
		
		shift--;
		
		for ( int rowNum = 0; rowNum < kNumAdjacentRows; ++rowNum ){

			unsigned long threeBits = 0;
			
			LifeRow row = source[ rowNum ];

			long wordIndex = col >> kWordShift;
			
			LifeWord word = row[ wordIndex ];

			if ( shift == -1 ){
				
				//shift = 0;
				//bitmask = 3;
				//bitmask = 6;
				
				unsigned int wordLeft = row[ wordIndex - 1 ];
				
				if ( wordLeft & 0x80000000 ){
					//threeBits = 0x00000004;
					threeBits = 0x00000001;
				}
	
				
				threeBits |= ( word << 1 ) & 6;			

			}else if ( shift == 30 ){
								
				unsigned long wordRight = row[ wordIndex + 1 ];
				
				// printf( "%lx\n", wordRight );
				
				if ( wordRight & 0x00000001 ){
					threeBits = 0x00000004;
				}
								
				threeBits |= ( word >> 30 ) & 3;
				
				//if ( threeBits != 0 )
				//	printf( "%lx\n", threeBits );
				
				assert( ( threeBits & 0xfffffff8 ) == 0 );
			}else{
	
				threeBits |= ( word >> shift ) & 0x00000007;			
			}
			
			index |= threeBits << threeShift;
			
			threeShift += 3;
		}
		
		
		long wordIndex = col >> kWordShift;
		long bitIndex = col & kWordMask;
		
		if ( gNeighborLut[ index ] == 0 ){
			
			dest[ wordIndex ] &= ~( 1 << bitIndex );
			
		}else{
			
			dest[ wordIndex ] |= 1 << bitIndex;
		}		 
	}
	
	return;
}
#endif

#if 0
static unsigned long ThreeBits( LifeRow row, long col )
{
	unsigned long result = 0;

	int shift = col & kWordMask;
	
	shift--;
	
	LifeWord bitmask;
	
	if ( shift == -1 ){

		shift = 0;
		bitmask = 3;

		unsigned int wordLeft = row[ ( col - 1 ) >> kWordShift ];
		
		if ( wordLeft & 0x80000000 )
			result = 0x00000004;
		
	}else if ( shift == 30 ){
		
		shift = 29;
		
		unsigned int wordRight = row[ ( col + 1 ) >> kWordShift ];
		
		if ( wordRight & 0x00000001 )
			result = 0x00000001;
		
		bitmask = 0x00000006;
	}else{
				
		bitmask = 0x00000007;
	}
	
	LifeWord word = row[ col >> kWordShift ];
	
	result |= ( word >> shift ) & bitmask;
	
	return result;
}
#endif

#if 0
int NeighborLookup( LifeRow upperRow, LifeRow thisRow, LifeRow lowerRow, long col )
{
	unsigned long index;

	index = ThreeBits( thisRow, col );
	
	index |= ThreeBits( upperRow, col ) << 3;
	
	index |= ThreeBits( lowerRow, col ) << 6;
	
	return gNeighborLut[ index ];
}
#endif

CellRun NextRun( LifeRow row, long rowLen, CellRun prevRun )
{
	long test = prevRun.col + prevRun.count;
	
	CellRun newRun;
	
	newRun.col = FindBit( row, rowLen, test, 1 );
	
	if ( newRun.col == -1 ){
		newRun.col = rowLen;
		newRun.count = 0;
		
		return newRun;
	}
	
	long nextZero = FindBit( row, rowLen, newRun.col, 0 );
	
	if ( nextZero == -1 ){
		
		newRun.count = rowLen - newRun.col;
		
		return newRun;
	}
	
	newRun.count = nextZero - newRun.col;
	
	return newRun;
}
			
long FindBit( LifeRow row, long rowLen, long start, int set )
{
    // BUG TODO This is implicitly hardwired for 32-bit, also maximum row length of 2^32 cells

	unsigned int result = (unsigned int)start;

	while ( result < rowLen ){
		
		unsigned int word = (unsigned int)row[ result >> kWordShift ];
		
		if ( set && word == 0 ){
			
			result += 32 - ( result & kWordMask );
			
			continue;
		}

#if 1
		if ( ( result & kWordMask ) == 0 ){
			
			if ( !set )
				word = ~word;
							
			int firstBit = __builtin_ffs( word );
				
			--firstBit;
			
			result += firstBit;
			
			break;
		}else{
#endif
			unsigned int bit = result & kWordMask;
			
			while ( bit < 32 ){
				
				long mask = 0x01 << bit;
				
				if ( ( set && ( ( word & mask ) != 0 ) ) || ( !set && ( ( word & mask ) == 0 ) ) )
					break;
				
				++bit;
			}
			
			if ( bit < 32 ){
				
				// We found a bit
				
				result = result + ( bit - ( result & kWordMask ) );

				break;
			}
			
			result += 32 - ( result & kWordMask );
#if 1
		}
#endif
	}
	
	if ( result >= rowLen )
		return -1;

	return result;
}

void Clear( LifeRow row, long columns )
{
	long words = Words( columns );
	
	for ( long word = 0; word < words; ++word )
		row[ word ] = 0;
	
	return;
}

int HasLivingCells( LifeRow row, long columns )
{
	for ( long col = 0; col < columns; ++col ){
		if ( Get( row, col ) )
			return 1;
	}
	
	return 0;
}

long LeftMostCell( LifeRow row, long columns )
{
	for ( long col = 0; col < columns; ++col ){
		if ( Get( row, col ) )
			return col;
	}
	
	return -1;
}

long RightMostCell( LifeRow row, long columns )
{
#if 0
	for ( long col = columns; col >= 0; --col ){
		if ( Get( row, col ) )
			return col;
	}
#endif
    for ( long col = columns - 1; col >= 0; --col ){
		if ( Get( row, col ) )
			return col;
	}

	return -1;
}

