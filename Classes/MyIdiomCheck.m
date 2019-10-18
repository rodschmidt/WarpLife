//
//  MyIdiomCheck.m
//  LifeIPhone_3.0
//
//  Created by Michael D. Crawford on 9/20/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "MyIdiomCheck.h"

int MyIdiomCheck( void )
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	
	if ( ![[UIDevice currentDevice] respondsToSelector: @selector( userInterfaceIdiom ) ] )
		return kiPhoneIdiom;

	int idiom = [UIDevice currentDevice].userInterfaceIdiom;

	switch( idiom ){
		case UIUserInterfaceIdiomPad:
		return kiPadIdiom;

		case UIUserInterfaceIdiomPhone:
		default:
			return kiPhoneIdiom;
			
	}
#else
	return kiPhoneIdiom;
#endif
}
			