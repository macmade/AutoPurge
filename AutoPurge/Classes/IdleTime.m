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

#import "IdleTime.h"

@implementation IdleTime

- ( id )init
{
    kern_return_t status;
    
    if( ( self = [ super init ] ) ) {
        
        status = IOMasterPort( MACH_PORT_NULL, &_ioPort );
        
        if( status != KERN_SUCCESS ) {
            
            @throw [ NSException
                        exceptionWithName:  @"IdleTimeIOKitError"
                        reason:             @"Error communicating with IOKit"
                        userInfo:           nil
                   ];
        }
        
        status = IOServiceGetMatchingServices(
            _ioPort,
            IOServiceMatching( "IOHIDSystem" ),
            &_ioIterator
        );
        
        if( status != KERN_SUCCESS ) {
            
            @throw [ NSException
                        exceptionWithName:  @"IdleTimeIOHIDError"
                        reason:             @"Error accessing IOHIDSystem"
                        userInfo:           nil
                   ];
        }
        
        _ioObject = IOIteratorNext( _ioIterator );
        
        if ( _ioObject == 0 ) {
            
            IOObjectRelease( _ioIterator );
            
            @throw [ NSException
                        exceptionWithName:  @"IdleTimeIteratorError"
                        reason:             @"Invalid iterator"
                        userInfo:           nil
                   ];
        }
        
        IOObjectRetain( _ioObject );
        IOObjectRetain( _ioIterator );
    }
    
    return self;
}

- ( void )dealloc
{
    IOObjectRelease( _ioObject );
    IOObjectRelease( _ioIterator );
    
    [ super dealloc ];
}

- ( uint64_t )timeIdle
{
    kern_return_t          status;
    CFTypeRef              idle;
    CFTypeID               type;
    uint64_t               time;
    CFMutableDictionaryRef properties;
    
    properties = NULL;

    status = IORegistryEntryCreateCFProperties(
        _ioObject,
        &properties,
        kCFAllocatorDefault,
        0
    );
    
    if( status != KERN_SUCCESS || properties == NULL ) {
        
        @throw [ NSException
                    exceptionWithName:  @"IdleTimeSystemPropError"
                    reason:             @"Cannot get system properties"
                    userInfo:           nil
               ];
    }
    
    idle = CFDictionaryGetValue( properties, CFSTR( "HIDIdleTime" ) );
    
    if( !idle ) {
        
        CFRelease( ( CFTypeRef )properties );
        
        @throw [ NSException
                    exceptionWithName:  @"IdleTimeSystemTimeError"
                    reason:             @"Cannot get system idle time"
                    userInfo:           nil
               ];
    }
    
    CFRetain( idle );
    
    type = CFGetTypeID( idle );
    
    if( type == CFDataGetTypeID() ) {
        
        CFDataGetBytes(
            ( CFDataRef )idle,
            CFRangeMake( 0, sizeof( time ) ),
            ( UInt8 * )&time
        );
        
    } else if( type == CFNumberGetTypeID() ) {
        
        CFNumberGetValue(
            ( CFNumberRef )idle,
            kCFNumberSInt64Type,
            &time
        );
        
    } else {
        
        CFRelease( idle );
        CFRelease( ( CFTypeRef )properties );
        
        @throw [ NSException
                    exceptionWithName:  @"IdleTimeTypeError"
                    reason:             [ NSString stringWithFormat: @"Unsupported type: %d\n", ( int )type ]
                    userInfo:           nil
               ];
    }
    
    CFRelease( idle );
    CFRelease( ( CFTypeRef )properties );
    
    return time;
}

- ( NSUInteger )secondsIdle
{
    uint64_t time;
    
    time = self.timeIdle;
    
    return ( NSUInteger )( time >> 30 );
}

@end
