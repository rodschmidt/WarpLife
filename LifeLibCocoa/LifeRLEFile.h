//
//  LifeRLEFile.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/31/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LifeGrid;

@interface LifeRLEFile : NSObject {
	

}

enum{
	kFileCorrupted,
	kInsufficientMemory,
	kCantOpenFile,
	kHeaderCorrupted
};

+ (BOOL) write: (LifeGrid*) grid path: (NSString*) path start: (BOOL) writeStart;
+ (BOOL) writeBuffer: (char*) buf handle: (id) handle lineLength: (int*) lineLength;

+ (LifeGrid*) alloc: (NSString*) path error: (int*) error;
+ (BOOL) readHeader: (id) fileHandle grid: (LifeGrid*) grid error: (int*) error;

+ (BOOL) readRow: (id) fileHandle 
			grid: (LifeGrid*) grid 
			 row: (long*) rowPtr 
			 eof: (BOOL*) eofPtr
		   error: (int*) error;

+ (BOOL) readTag: (id) fileHandle 
	   runLength: (long*) runLengthPtr 
		   alive: (BOOL*) alivePtr
			rows: (long*) rowPtr
			 eof: (BOOL*) eofPtr
		   error: (int*) error;

+ (BOOL) eatEOLMarker: (id) fileHandle eof: (BOOL*) eofPtr;
+ (BOOL) eatWhiteSpace: (id) fileHandle;
+ (BOOL) eatComment: (id) fileHandle;
+ (void) eatEOL: (id) fileHandle;

@end
