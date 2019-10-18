//
//  AllSubviews.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/7/10.
//  Copyright 2010 Microsoft. All rights reserved.
// 

#import "AllSubviews.h"

NSArray *allSubviews( UIView *aView )
{
	NSArray *results = [aView subviews];
	
	for ( UIView *eachView in [aView subviews] ){
		NSArray *riz = allSubviews( eachView );
		
		if ( riz )
			results = [results arrayByAddingObjectsFromArray: riz];
	}
	
	return results;
}

