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

#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <IOKit/IOKitLib.h>

@interface IdleTime: NSObject
{
@protected
    
    mach_port_t   _ioPort;
    io_iterator_t _ioIterator;
    io_object_t   _ioObject;
    
@private
    
    id _Execution_Reserved[ 5 ] __attribute__( ( unused ) );
}

@property( readonly ) uint64_t timeIdle;
@property( readonly ) NSUInteger secondsIdle;

@end
