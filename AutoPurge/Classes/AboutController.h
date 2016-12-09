/*******************************************************************************
 * Copyright (c) 2011, Jean-David Gadina <macmade@eosgarden.com>
 * All rights reserved
 ******************************************************************************/
 
/* $Id$ */

/*!
 * @header      ...
 * @copyright   eosgarden 2011 - Jean-David Gadina <macmade@eosgarden.com>
 * @abstract    ...
 */

@interface AboutController: NSWindowController
{
@protected
    
    NSTextField * _versionField;
    
@private
    
    id _AboutController_Reserved[ 5 ] __attribute__( ( unused ) );
}

@property( nonatomic, retain ) IBOutlet NSTextField * versionField;

@end
