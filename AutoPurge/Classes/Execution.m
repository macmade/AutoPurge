/*******************************************************************************
 * Copyright (c) 2011, Jean-David Gadina <macmade@eosgarden.com>
 * All rights reserved
 ******************************************************************************/
 
/* $Id$ */

/*!
 * @file        Execution.m
 * @copyright   eosgarden 2011 - Jean-David Gadina <macmade@eosgarden.com>
 * @abstract    ...
 */

#import "Execution.h"

@implementation Execution

@synthesize canExecuteWithPrivilege = _canExecuteWithPrivilege;
@synthesize authorizationRef        = _authorizationRef;

- ( OSStatus )authorizeExecute
{
    OSStatus status;
    AuthorizationFlags flags;
    AuthorizationItem item;
    AuthorizationRights rights;
    
    flags  = kAuthorizationFlagDefaults;
    status = AuthorizationCreate
    (
         NULL,
         kAuthorizationEmptyEnvironment,
         flags,
         &_authorizationRef
     );
    
    if( status == errAuthorizationSuccess )
    {
        item.name        =  kAuthorizationRightExecute;
        item.valueLength =  0;
        item.value       =  NULL;
        item.flags       =  0;
        rights.count     =  1;
        rights.items     =& item;
        
        flags = kAuthorizationFlagDefaults
              | kAuthorizationFlagInteractionAllowed
              | kAuthorizationFlagPreAuthorize
              | kAuthorizationFlagExtendRights;
        
        status = AuthorizationCopyRights
        (
             _authorizationRef,
             &rights,
             NULL,
             flags,
             NULL
         );
        
        if( status == errAuthorizationSuccess )
        {
            _canExecuteWithPrivilege = YES;
            return status;
        }
    }
    
    _canExecuteWithPrivilege = NO;
    return status;
}

- ( OSStatus )executeWithPrivileges: ( char * )command arguments: ( char * [] )arguments io: ( FILE ** )io
{
    OSStatus status;
    AuthorizationFlags flags;
    
    status = 0;
    
    if( _canExecuteWithPrivilege == NO )
    {
        status = [ self authorizeExecute ];
    }
    
    if( status != errAuthorizationSuccess )
    {
        return status;
    }
    
    flags  = kAuthorizationFlagDefaults;
    status = AuthorizationExecuteWithPrivileges
    (
        _authorizationRef,
        command,
        flags,
        arguments,
        io
    );
    
    return status;
}

- ( NSFileHandle * )execute: ( NSString * )command arguments: ( NSArray * )arguments
{
    NSFileHandle * io;
    NSTask       * task;
    NSPipe       * execPipe;
    
    task = [ [ [ NSTask alloc ] init ] autorelease ];
    
    [ task setLaunchPath: command ];
    [ task setArguments: arguments ];
    
    execPipe = [ NSPipe pipe ];
    
    [ task setStandardOutput: execPipe ];
    
    io = [ execPipe fileHandleForReading ];
    
    [ task launch ];
    
    return io;
}

- ( NSFileHandle * )open: ( NSString * )target
{
    NSArray *args;
    
    args = [ NSArray arrayWithObjects: target, nil ];
    
    return [ self execute: @"/usr/bin/open" arguments: args ];
}

@end
