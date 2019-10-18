//
//  RLEFileArray.h
//  Warp Life
//
//  Created by Michael D. Crawford on 1/24/14.
//
//

#import <Foundation/Foundation.h>

@interface RLEFileArray : NSMutableArray{
    NSMutableArray  *imp;
}

- (RLEFileArray*) init;
- (NSUInteger) count;
- (void) addObject: (id) object;
- (id)objectAtIndex:(NSUInteger)index;
- (void) remove: (NSString*) file;
+ (NSString*) documentDirectoryPath;

@end



