//
//  LifeDisplay.h
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/29/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "GridCoord.h"

@class LifeGrid;

@interface LifeDisplay : UIView {

	float       scale;
	CGPoint     origin;
	LifeGrid    *grid;
}

@property (assign) float scale;
@property (assign) CGPoint origin;
//@property (retain, nonatomic) IBOutlet LifeGrid *grid;
@property (assign) IBOutlet LifeGrid *grid;
@property (assign, nonatomic) uint64_t drawTime;

- (id) initWithCoder: (NSCoder*) coder;
- (void) dealloc;

- (GridCoord) center;

- (GridCoord) pointToCoord: (CGPoint) where;
- (GridLocation) pointToLocation: (CGPoint) where;

- (CGPoint) pinOrigin: (CGPoint) origin;
- (float) pinScale: (float) scale;

- (void) centerImage;

- (void) setSpeed: (float) speed;

@end
