//
//  RepositionSubviews.m
//  LifeIPhone
//
//  Created by Michael D. Crawford on 9/9/10.
//  Copyright 2010 Michael David Crawford. All rights reserved.
//

#import "RepositionSubviews.h"

#import <UIKit/UIKit.h>

#include "AllSubviews.h"

void repositionSubviews( UIView *superview, UIView *theTemplate )
{
	if ( !theTemplate )
		return;

	for ( UIView *eachView in allSubviews( theTemplate )){
		
		NSInteger tag = eachView.tag;
		
		if ( tag < 10 ) continue;
		
		[superview viewWithTag: tag].frame = eachView.frame;
	}
	
	return;
}

#if 0
void repositionSubviews( UIView *superview, UIView *theTemplate )
{
	if ( !theTemplate )
		return;
    
    NSArray *templateViews = allSubviews( theTemplate );
    NSArray *ourViews = allSubviews( superview );

	for ( UIView *eachView in ourViews ){
		
        for ( UIView *tV in templateViews ){
            
            if ( [tV class] == [eachView class] ){
                
                NSString *className = NSStringFromClass( [eachView class] );
                
                if ( [className compare: @"UILabel"] ){
                    
                    if ( [ ((UILabel*)tV).text compare: ((UILabel*)eachView).text] )
                        eachView.frame = tV.frame;
                }
                
            }
        }
		eachView.frame = eachView.frame;
	}
	
	return;
}
#endif

