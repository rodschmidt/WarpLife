//
//  LifeDisplay.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 8/29/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "LifeDisplay.h"

#import "LifeGrid.h"

@implementation LifeDisplay

@synthesize scale;
@synthesize origin;
@synthesize grid;
@synthesize drawTime;

- (id) initWithCoder: (NSCoder*) coder
{
	if ( self = [super initWithCoder: coder] ){
		
		scale = 40.0;
		
		CGPoint theOrigin;
		theOrigin.x = 0;
		theOrigin.y = 0;
		
		origin = theOrigin;
	}
	
	return self;
}

- (void) dealloc
{
    [grid release];
    
    [super dealloc];

    return;
}

- (GridCoord) pointToCoord: (CGPoint) where
{
	GridCoord result;
	
	result.col = self.origin.x + ( where.x / self.scale );
	result.row = self.origin.y + ( where.y / self.scale );
	
	return result;
}

- (GridLocation) pointToLocation: (CGPoint) where
{
    GridLocation result;
    
    result.col = self.origin.x + ( where.x / self.scale );
    result.row = self.origin.y + ( where.y / self.scale );
    
    return result;
}

- (GridCoord) center
{
	CGPoint ctPt;
	
	ctPt.x = self.frame.origin.x + ( self.frame.size.width / 2.0 );
	ctPt.y = self.frame.origin.y + ( self.frame.size.height / 2.0 );
	
	return [self pointToCoord: ctPt];
}

- (CGPoint) pinOrigin: (CGPoint) newOrigin
{
	//printf( "%f %f ", origin.x, origin.y );
	
	if ( newOrigin.y < 0 ){
		newOrigin.y = 0;
	}
	
	if ( newOrigin.x < 0 ){
		newOrigin.x = 0;
	}
	
	long maxRow = [self.grid height] - ( self.bounds.size.height / self.scale );
	
	if ( newOrigin.y > maxRow ){
		newOrigin.y = maxRow;
	}
	
	long maxCol = [self.grid width] - ( self.bounds.size.width / self.scale );
	
	if ( newOrigin.x > maxCol ){
		newOrigin.x = maxCol;
	}
	
	//printf( "%f %f\n", origin.x, origin.y );
	
	return newOrigin;
}

- (float) pinScale: (float) newScale
{
	float minX = self.frame.size.width / self.grid.width;
	float minY = self.frame.size.height / self.grid.height;
	
	float min = MAX( minX, minY );
	
	if ( newScale < min )
		newScale = min;
	
	// Do we want a maximum scale?
	
	return newScale;
}


- (void) centerImage
{
	GridCoord boundOrigin;
	GridCoord boundSize;
	
	[self.grid boundingBox: &boundOrigin size: &boundSize];
	
	if ( boundSize.col == -1 || boundSize.row == -1 )
		return;

	float horzScale = ( self.frame.size.width - 20 ) / boundSize.col;
	float vertScale = ( self.frame.size.height - 20 ) / boundSize.row;
	
	float newScale = [self pinScale: MIN( horzScale, vertScale )];
	
	if ( newScale > 15 )
		newScale = 15;
	
	self.scale = newScale;
	
	
	GridCoord center;
	center.col = boundOrigin.col + ( boundSize.col / 2 );
	center.row = boundOrigin.row + ( boundSize.row / 2 );
	
	CGPoint newOrigin;
	
	float width = self.frame.size.width;
	float height = self.frame.size.height;
	
	newOrigin.x = center.col - ( width / ( 2.0 * self.scale ) );
	newOrigin.y = center.row - ( height / ( 2.0 * self.scale ) );
	
	self.origin = [self pinOrigin: newOrigin];

	[self setNeedsDisplay];

	return;
}

- (void) setSpeed: (float) speed
{
    [self.grid setSpeed: speed];
    
    return;
}

@end
