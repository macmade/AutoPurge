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

#import "Memory.h"
#import <sys/sysctl.h>
#import <mach/mach_host.h>

static Memory * __sharedInstance = nil;

@interface Memory( Private )

- ( void )updateMemoryUsage: ( NSTimer * )timer;
- ( NSString * )humanReadableSize: ( unsigned long )bytes;

@end

@implementation Memory( Private )

- ( void )updateMemoryUsage: ( NSTimer * )timer
{
    mach_port_t             hostPort;
    mach_msg_type_number_t  hostSize;
    vm_size_t               pageSize;
    vm_statistics_data_t    vmStat;
    
    ( void )timer;
    
    hostPort = mach_host_self();
    hostSize = sizeof( vm_statistics_data_t ) / sizeof( integer_t );
    
    host_page_size( hostPort, &pageSize );
    
    if( host_statistics( hostPort, HOST_VM_INFO, ( host_info_t )&vmStat, &hostSize ) != KERN_SUCCESS )
    {
        return;
    }
    
    _wiredBytes     = vmStat.wire_count     * pageSize;
    _activeBytes    = vmStat.active_count   * pageSize;
    _inactiveBytes  = vmStat.inactive_count * pageSize;
    _freeBytes      = vmStat.free_count     * pageSize;
    _totalBytes     = _wiredBytes
                    + _activeBytes
                    + _inactiveBytes
                    + _freeBytes;
}

- ( NSString * )humanReadableSize: ( unsigned long )bytes
{
    NSString * unit;
    double     size;
    BOOL       inBytes;
    
    inBytes = NO;
    
    if( bytes > ( 1024 * 1024 * 1024 ) )
    {
        unit = NSLocalizedString( @"unitGigaBytes", nil );
        size = ( double )( ( double )( ( double )bytes / ( double )1024 ) / ( double )1024 ) / ( double )1024;
    }
    else if( bytes > ( 1024 * 1024 ) )
    {
        unit = NSLocalizedString( @"unitMegaBytes", nil );
        size = ( double )( ( double )bytes / ( double )1024 ) / ( double )1024;
    }
    else if( bytes > 1024 )
    {
        unit = NSLocalizedString( @"unitKiloBytes", nil );
        size = ( double )( ( double )bytes / ( double )1024 );
    }
    else
    {
        unit    = NSLocalizedString( @"unitBytes", nil );
        inBytes = YES;
    }
    
    if( inBytes == YES )
    {
        return [ NSString stringWithFormat: @"%lu %@", bytes, unit ];
    }
    
    return [ NSString stringWithFormat: @"%0.2f %@", size, unit ];
}

@end

@implementation Memory

@synthesize totalBytes    = _totalBytes;
@synthesize wiredBytes    = _wiredBytes;
@synthesize activeBytes   = _activeBytes;
@synthesize inactiveBytes = _inactiveBytes;
@synthesize freeBytes     = _freeBytes;

+ ( id )sharedInstance
{
    @synchronized( self )
    {
        if( __sharedInstance == nil )
        {
            __sharedInstance = [ [ super allocWithZone: NULL ] init ];
        }
    }
    
    return __sharedInstance;
}

+ ( id )allocWithZone:( NSZone * )zone
{
    ( void )zone;
    
    @synchronized( self )
    {
        return [ [ self sharedInstance ] retain ];
    }
}

- ( id )copyWithZone:( NSZone * )zone
{
    ( void )zone;
    
    return self;
}

- ( id )retain
{
    return self;
}

- ( NSUInteger )retainCount
{
    return UINT_MAX;
}

- ( oneway void )release
{}

- ( id )autorelease
{
    return self;
}

- ( id )init
{
    if( ( self = [ super init ] ) )
    {
        [ self updateMemoryUsage: nil ];
        
        _timer = [ NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector( updateMemoryUsage: ) userInfo: nil repeats: YES ];
    }
    
    return self;
}

- ( void )dealloc
{
    [ _timer invalidate ];
    [ super dealloc ];
}

- ( NSString * )total
{
    @synchronized( self )
    {
        return [ self humanReadableSize: _totalBytes ];
    }
}

- ( NSString * )wired
{
    @synchronized( self )
    {
        return [ self humanReadableSize: _wiredBytes ];
    }
}

- ( NSString * )active
{
    @synchronized( self )
    {
        return [ self humanReadableSize: _activeBytes ];
    }
}

- ( NSString * )inactive
{
    @synchronized( self )
    {
        return [ self humanReadableSize: _inactiveBytes ];
    }
}

- ( NSString * )free
{
    @synchronized( self )
    {
        return [ self humanReadableSize: _freeBytes ];
    }
}

@end
