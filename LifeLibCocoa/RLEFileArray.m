//
//  RLEFileArray.m
//  Warp Life
//
//  Created by Michael D. Crawford on 1/24/14.
//
//

#import "RLEFileArray.h"

@implementation RLEFileArray

- (RLEFileArray*) init
{
    if ( self = [super init]){
        imp = [[NSMutableArray alloc] init];
        if ( nil == imp )
            return nil;

        // There might be no files at all.
        
        NSString *path = [RLEFileArray documentDirectoryPath];
        
        NSLog( @"%@", path );

        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager]
                                          enumeratorAtPath: path];
        
        NSString *fileName;
        
        while ( ( fileName = [dirEnum nextObject] ) ){
            
            NSLog( @"%@", fileName );

            if ( [fileName hasSuffix: @".rle"] ){
                [self addObject: fileName];
            }
        }
	}

	return self;
}

- (NSUInteger) count
{
    return [imp count];
}

- (void) addObject: (id) object
{
    [imp addObject: object];
    
    return;
}

- (void) remove: (NSString*) file
{
    [imp removeObject: file];
    
    return;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [imp objectAtIndex: index];
}

+ (NSString*) documentDirectoryPath
{
	return [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
}

@end

