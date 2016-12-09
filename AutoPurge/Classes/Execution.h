/*******************************************************************************
 * Copyright (c) 2011, Jean-David Gadina <macmade@eosgarden.com>
 * All rights reserved
 ******************************************************************************/
 
/* $Id$ */

/*!
 * @header      Execution.h
 * @copyright   eosgarden 2011 - Jean-David Gadina <macmade@eosgarden.com>
 * @abstract    ...
 */

/*!
 * @class       Execution
 * @abstract    ...
 */
@interface Execution: NSObject
{
@protected
    
    BOOL             _canExecuteWithPrivilege;
    AuthorizationRef _authorizationRef;
    
@private
    
    id _Execution_Reserved[ 5 ] __attribute__( ( unused ) );
}

@property( atomic, readonly ) BOOL             canExecuteWithPrivilege;
@property( atomic, readonly ) AuthorizationRef authorizationRef;

- ( OSStatus )authorizeExecute;
- ( OSStatus )executeWithPrivileges: ( char * )command arguments: ( char * [] )arguments io: ( FILE ** )io;
- ( NSFileHandle * )execute: ( NSString * )command arguments: ( NSArray * )arguments;
- ( NSFileHandle * )open: ( NSString * )target;

@end
