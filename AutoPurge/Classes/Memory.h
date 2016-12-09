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

@interface Memory: NSObject
{
@protected
    
    unsigned long _totalBytes;
    unsigned long _wiredBytes;
    unsigned long _activeBytes;
    unsigned long _inactiveBytes;
    unsigned long _freeBytes;
    NSTimer     * _timer;
    
@private
    
    id _Memory_Reserved[ 5 ] __attribute__( ( unused ) );
}

@property( atomic, readonly ) unsigned long totalBytes;
@property( atomic, readonly ) unsigned long wiredBytes;
@property( atomic, readonly ) unsigned long activeBytes;
@property( atomic, readonly ) unsigned long inactiveBytes;
@property( atomic, readonly ) unsigned long freeBytes;
@property( atomic, readonly ) NSString * total;
@property( atomic, readonly ) NSString * wired;
@property( atomic, readonly ) NSString * active;
@property( atomic, readonly ) NSString * inactive;
@property( atomic, readonly ) NSString * free;

+ ( Memory * )sharedInstance;

@end
