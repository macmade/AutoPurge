/*******************************************************************************
 * Copyright (c) 2011, Jean-David Gadina <macmade@eosgarden.com>
 * All rights reserved
 ******************************************************************************/
 
/* $Id$ */

/*!
 * @file        ...
 * @copyright   eosgarden 2011 - Jean-David Gadina <macmade@eosgarden.com>
 * @abstract    ...
 */

#import "AboutController.h"

@implementation AboutController

@synthesize versionField = _versionField;

- ( id )init
{
    if( [ super initWithWindowNibName: @"About" ] )
    {}
    
    return self;
}

- ( void )dealloc
{
    [ _versionField release ];
    
    [ super dealloc ];
}

- ( void )windowDidLoad
{
    [ _versionField setStringValue: [ [ NSBundle mainBundle ] objectForInfoDictionaryKey: @"CFBundleShortVersionString" ] ];
    [ super windowDidLoad ];
}

@end
