//
//  LifeRLEFile.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "LifeRLEFile.h"

#include <stdio.h>

#import "LifeGrid.h"
#import "CellRun.h"

@implementation LifeRLEFile

+ (BOOL) write: (LifeGrid*) grid path: (NSString*) path start: (BOOL) writeStart
{
	NSData *initData = [NSData data];
	
	if ( ![[NSFileManager defaultManager] createFileAtPath: path contents: initData attributes: NULL] )
		return NO;

	id handle = [NSFileHandle fileHandleForWritingAtPath: path];

	if ( handle == NULL )
		return NO;
	
	GridCoord boundOrigin;
	GridCoord boundSize;
	
	if ( writeStart )
		[grid startBoundingBox: &boundOrigin size: &boundSize];
	else
		[grid boundingBox: &boundOrigin size: &boundSize];

	char buf[ 80 ];
	int lineLength = 0;
	
	snprintf( buf, 80, "x = %ld, y = %ld\n", boundSize.col, boundSize.row );
	
	[LifeRLEFile writeBuffer: buf handle: handle lineLength: &lineLength];
	
	
	for ( long row = boundOrigin.row; row < boundOrigin.row + boundSize.row; ++row ){

		LifeRow cellRow = writeStart ? [grid getStartRow: row] : [grid getRow: row];
		
		CellRun living;
		
		living.col = boundOrigin.col;
		//printf ( "living.col=%ld\n", living.col );
		living.count = 0;
		
		long prev = living.col;
		
		long curCol = living.col;
		
		while ( living.col + living.count < ( boundOrigin.col + boundSize.col ) ){
			
			living = [grid nextRun: living row: cellRow];
			
			if ( living.col != prev ){
				
				long run = living.col - prev;
				
				curCol += run;
				
				if ( curCol > ( boundOrigin.col + boundSize.col ) ){
					run -= 1 + ( curCol - ( boundOrigin.col + boundSize.col ) );
				}
				
				snprintf( buf, 80, "%ldb", run );
			
				[self writeBuffer: buf handle: handle lineLength: &lineLength];
			}
			
			if ( curCol < [grid width] && living.count != 0 ){
				
				long run = living.count;
				
				if ( curCol + run > ( boundOrigin.col + boundSize.col ) ){
					run = ( boundOrigin.col + boundSize.col ) - curCol;
				}
				
				snprintf( buf, 80, "%ldo", run );
			
				[self writeBuffer: buf handle: handle lineLength: &lineLength];
			}
			
			prev = living.col + living.count;
						
		}
		
		[self writeBuffer: "$" handle: handle lineLength: &lineLength];
	}
	
	[self writeBuffer: "!" handle: handle lineLength: &lineLength];

	[handle closeFile];

	return YES;
}

+ (BOOL) writeBuffer: (char*) buf handle: (id) handle lineLength: (int*) lineLength
{
	unsigned long len = strlen( buf );
	
	if ( *lineLength + len > 70 ){
		NSData *data = [NSData dataWithBytes: "\n" length: 1];

		[handle writeData: data];
		
		*lineLength = 0;
	}
	
	NSData *data = [NSData dataWithBytes: buf length: len];
	
	*lineLength += len;
	
	// TODO: writeData throws an exception on error.  Handle it!
	
	[handle writeData: data];
	
	return YES;
}
	
+ (LifeGrid*) alloc: (NSString*) path error: (int*) error
{
	LifeGrid *result = [[LifeGrid alloc] init];
	
	id handle = [NSFileHandle fileHandleForReadingAtPath: path];
	
	if ( NULL == handle ){
		
		[result release];
		
		*error = kCantOpenFile;
		
		[handle closeFile];
		
		return NULL;
	}
	
	while ( [self eatComment: handle] ){
	}
	
	if ( ![self readHeader: handle grid: result error: error] ){
		[result release];
        [handle closeFile];
		return NULL;
	}
	
	if ( ![result initGrid] ){
        [result release];
		*error = kInsufficientMemory;
		return NULL;
	}

	long row;
	
	BOOL eof = NO;
	
	row = 0;
	
	while ( row < [result height] ){

		if ( ![self readRow: handle grid: result row: &row eof: &eof error: error] ){
			[result release];
			return NULL;
		}
		
		if ( eof ){
			++row;
			break;
		}
	}
	
	if ( row < [result height] ){
		if ( !eof ){
            [result release];
			return kFileCorrupted;
		}else{
			while ( row < [result height]){
				
				LifeRow lifeRow = [result getRow: row];

				for ( long col = 0; col < [result width]; ++col ){
					Set( lifeRow, col, 0 );
				}
				
				++row;
			}
			
		}
	}

	return result;
}

enum{
	kX,
	kEquals,
	kNumber,
	kComma,
	kY,
	kEOL,
	kNextLine
};

+ (BOOL) readHeader: (id) fileHandle grid: (LifeGrid*) grid error: (int*) error
{
	NSData *data;
	BOOL done = NO;
	int expect = kX;
	int x = -1;
	int y = -1;
	int tally = 0;
	
	while ( !done ){
		data = [fileHandle readDataOfLength: 1];
		
		char buf;
		
		[data getBytes: &buf length: 1];
		
		switch( buf ){
			case ' ':
				if ( expect == kNumber ){
					if ( tally != 0 ){
						if ( x == -1 ){
							x = tally;
							expect = kComma;
						}else{
							y = tally;
							expect = kEOL;
						}
					}
				}
				break;
				
			case 'x':
				
				if ( expect == kX ){
					expect = kEquals;
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}
				
				break;
				
			case '=':
				if ( expect == kEquals ){
					expect = kNumber;
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}
				break;
				
			case ',':
				if ( expect == kComma || expect == kNumber ){
					if ( x == -1 ){
						x = tally;
						tally = 0;
						expect = kY;
					}else if ( y == -1 ){
						y = tally;
						[self eatEOL: fileHandle];
						done = YES;
					}
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}
				break;
				
			case 'y':
				if ( expect == kY ){
					expect = kEquals;
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}
				break;
				
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				if ( expect == kNumber ){
					tally = ( tally * 10 ) + ( buf - '0' );
				}else if ( expect == kNextLine ){
					done = YES;
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}
				break;
				
			case '\r':
				if ( expect == kNumber ){
					y = tally;
					expect = kNextLine;
				}else if ( expect == kEOL || expect == kNextLine ){
					expect = kNextLine;
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}
				break;
				
			case '\n':
				if ( expect == kNumber ){
					y = tally;
					expect = kNextLine;
				}else if ( expect == kEOL || expect == kNextLine ){
					expect = kNextLine;
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}				
				break;
				
			default:
				if ( expect == kNextLine ){
					done = YES;
				}else{
					*error = kHeaderCorrupted;
					return NO;
				}
				break;
				
		}
	}
	
	[fileHandle seekToFileOffset: [fileHandle offsetInFile] - 1];
	
	[grid setWidth: x];
	[grid setHeight: y];
				
	return YES;
}

+ (BOOL) readRow: (id) fileHandle 
			grid: (LifeGrid*) grid 
			 row: (long*) rowPtr
			 eof: (BOOL*) eofPtr
		   error: (int*) error;
{
	long curCol = 0;
	
	LifeRow lifeRow = [grid getRow: *rowPtr];
	
	BOOL alive = NO;

	long origRow = *rowPtr;
	long newRows = 0;
	
	long runLen;

	while ( curCol < [grid width] ){
		
		runLen = [grid width] - curCol;
		
		
		if ( ![self readTag: fileHandle 
				  runLength: &runLen 
					  alive: &alive 
					   rows: &newRows
						eof: eofPtr 
					  error: error ] )
			return NO;
		
		for ( int i = 0; i < runLen; ++i ){
			Set( lifeRow, curCol++, alive ? 1 : 0 );
		}
	}
	
	if ( *eofPtr )
		return YES;

	if ( newRows == 0 ){
		[self readTag: fileHandle 
			runLength: &runLen 
				alive: &alive 
				 rows: &newRows
				  eof: eofPtr 
				error: error ];		
	}
	
	if ( *eofPtr )
		return YES;

	if ( newRows == 0 ){
		*error = kFileCorrupted;
		return NO;
	}

	*rowPtr = *rowPtr + newRows;
	
	for ( long row = origRow + 1; row < grid.height && row < *rowPtr; ++row ){
		
		lifeRow = [grid getRow: row];
		
		for ( long col = 0; col < grid.width; ++col ){
			Set( lifeRow, col, 0 );
		}
	}
	
	return YES;
}


+ (BOOL) readTag: (id) fileHandle 
	   runLength: (long*) runLengthPtr 
		   alive: (BOOL*) alivePtr
			rows: (long*) rowPtr
			 eof: (BOOL*) eofPtr
		   error: (int*) error
{
	[self eatWhiteSpace: fileHandle];
	
	*rowPtr = 0;
	
	*alivePtr = *alivePtr ? NO : YES;
	
	*eofPtr = NO;
	
	BOOL done = NO;
	long tally = 0;
	
	while ( !done ){
		NSData *data;
		
		data = [fileHandle readDataOfLength: 1];
		
		char buf;
		
		[data getBytes: &buf length: 1];
		
		switch ( buf ){
			case '$':
				if ( tally == 0 ){
					*rowPtr = 1;
				}else{
					*rowPtr = tally;
				}
				return YES;
				break;
				
			case '!':
				*eofPtr = YES;
				return YES;
				break;
				
			case 'b':
				*alivePtr = NO;
				done = YES;
				break;
				
			case 'o':
				*alivePtr = YES;
				done = YES;
				break;
				
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				tally = ( tally * 10 ) + ( buf - '0' );
				break;
				
			default:
				return FALSE;
		}
		
	}
		
	if ( tally == 0 ){
		*runLengthPtr = 1;
	}else{
		*runLengthPtr = tally;
	}
	
	return YES;
}

+ (BOOL) eatEOLMarker: (id) fileHandle eof: (BOOL*) eofPtr
{
	BOOL done = NO;
	
	while ( !done ){
		NSData *data;
		
		data = [fileHandle readDataOfLength: 1];
		
		char buf;
		
		[data getBytes: &buf length: 1];
		
		switch ( buf ){
			case '$':
				done = YES;
				break;
				
			case '!':
				*eofPtr = YES;
				done = YES;
				break;
				
			case ' ':
			case '\r':
			case '\n':
				break;
			
			case 'b':
			case 'o':
				break;
				
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				break;
		}
	}
				

		return YES;
}

+ (BOOL) eatWhiteSpace: (id) fileHandle
{
	BOOL done = NO;
	
	while ( !done ){
		NSData *data;
		
		data = [fileHandle readDataOfLength: 1];
		
		char buf;
		
		[data getBytes: &buf length: 1];
		
		switch ( buf ){
			case '\t':
			case ' ':
			case '\r':
			case '\n':
				break;
				
			default:
				done = true;
				
				
		}
	}
	
	[fileHandle seekToFileOffset: [fileHandle offsetInFile] - 1];

	return YES;
}

+ (BOOL) eatComment: (id) fileHandle
{
	NSData *data;
	
	data = [fileHandle readDataOfLength: 1];
	
	char buf;
	
	[data getBytes: &buf length: 1];
	
	if ( buf != '#' ){
		[fileHandle seekToFileOffset: [fileHandle offsetInFile] - 1];
		return NO;
	}
	
	[self eatEOL: fileHandle];
	
	return YES;
}

+ (void) eatEOL: (id) fileHandle
{
	BOOL eol = NO;
	NSData *data;
	char buf;
	
	while ( !eol ){

		data = [fileHandle readDataOfLength: 1];
		
	
		[data getBytes: &buf length: 1];
		
		if ( buf == '\r' || buf == '\n' )
			eol = YES;
	}

	data = [fileHandle readDataOfLength: 1];
	
	[data getBytes: &buf length: 1];
	
	if ( !( buf == '\r' || buf == '\n' ) )
		[fileHandle seekToFileOffset: [fileHandle offsetInFile] - 1];
	
	return;
}

@end
