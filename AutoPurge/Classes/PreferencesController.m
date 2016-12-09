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

#import "PreferencesController.h"

NSString * const PreferencesChangedNotification = @"PreferencesChangedNotification";

@interface PreferencesController( Private )

- ( BOOL )isLoginItemEnabled;
- ( void )enableLoginItem;
- ( void )disableLoginItem;

@end

@implementation PreferencesController( Private )

- ( BOOL )isLoginItemEnabled
{
    BOOL                    found;
    UInt32                  seedValue;
    CFURLRef                path;
    LSSharedFileListRef     loginItemsRef;
    CFArrayRef              loginItems;
    id                      loginItem;
    LSSharedFileListItemRef loginItemRef;
    
    found         = NO;
    seedValue     = 0;
    path          = NULL;
    loginItemsRef = LSSharedFileListCreate( NULL, kLSSharedFileListSessionLoginItems, NULL );
    
    if( !loginItemsRef )
    {
        return NO;
    }
    
    loginItems = LSSharedFileListCopySnapshot( loginItemsRef, &seedValue );
    
    for( loginItem in ( NSArray * )loginItems )
    {    
        loginItemRef = ( LSSharedFileListItemRef )loginItem;
        
        if( LSSharedFileListItemResolve( loginItemRef, 0, ( CFURLRef * )&path, NULL ) == noErr )
        {
            if( [ [ ( NSURL * )path path ] hasPrefix: [ [ NSBundle mainBundle ] bundlePath ] ] )
            {
                CFRelease( path );
                
                found = YES;
                
                break;
            }
            
            if( path != NULL )
            {
                CFRelease( path );
            }
        }
    }
    
    if( loginItems != NULL )
    {
        CFRelease( loginItems );
    }

    return found;
}

- ( void )enableLoginItem
{
    CFURLRef                url;
    LSSharedFileListRef     loginItemsRef;
    LSSharedFileListItemRef loginItemRef;
    
    url           = ( CFURLRef )[ NSURL fileURLWithPath: [ [ NSBundle mainBundle ] bundlePath ] ];
    loginItemsRef = LSSharedFileListCreate( NULL, kLSSharedFileListSessionLoginItems, NULL );
    
    if( !loginItemsRef )
    {
        return;
    }
    
	loginItemRef = LSSharedFileListInsertItemURL( loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL );		
	
    if( loginItemRef )
    {
		CFRelease( loginItemRef );
    }
}

- ( void )disableLoginItem
{
    UInt32                  seedValue;
    CFURLRef                path;
    CFArrayRef              loginItems;
    LSSharedFileListRef     loginItemsRef;
    id                      loginItem;
    LSSharedFileListItemRef loginItemRef;
    
    path          = NULL;
    seedValue     = 0;
    loginItemsRef = LSSharedFileListCreate( NULL, kLSSharedFileListSessionLoginItems, NULL );
    
    if( !loginItemsRef )
    {
        return;
    }
    
    loginItems = LSSharedFileListCopySnapshot( loginItemsRef, &seedValue );
    
    for( loginItem in ( NSArray * )loginItems )
    {		
        loginItemRef = ( LSSharedFileListItemRef )loginItem;
        
        if( LSSharedFileListItemResolve( loginItemRef, 0, ( CFURLRef * )&path, NULL ) == noErr )
        {
            if( [ [ ( NSURL * )path path ] hasPrefix: [ [ NSBundle mainBundle ] bundlePath ] ] )
            {
                CFRelease( path );
                LSSharedFileListItemRemove( loginItemsRef, loginItemRef );
                
                break;
            }
            
            if( path != NULL )
            {
                CFRelease( path );
            }
        }		
    }
    
    if( loginItems != NULL )
    {
        CFRelease( loginItems );
    }
}

@end

@implementation PreferencesController

@synthesize loginCheckbox     = _loginCheckbox;
@synthesize autoPurgeCheckbox = _autoPurgeCheckbox;
@synthesize idleCheckbox      = _idleCheckbox;
@synthesize autoPurgeSlider   = _autoPurgeSlider;
@synthesize idleSlider        = _idleSlider;
@synthesize autoPurgeText     = _autoPurgeText;
@synthesize idleText          = _idleText;

- ( id )init
{
    if( [ super initWithWindowNibName: @"Preferences" ] )
    {}
    
    return self;
}

- ( void )dealloc
{
    [ _loginCheckbox     release ];
    [ _autoPurgeCheckbox release ];
    [ _idleCheckbox      release ];
    [ _autoPurgeSlider   release ];
    [ _idleSlider        release ];
    [ _autoPurgeText     release ];
    [ _idleText          release ];
    
    [ super dealloc ];
}

- ( void )windowDidLoad
{
    [ super windowDidLoad ];
}

- ( IBAction )cancel: ( id )sender
{
    ( void )sender;
    
    [ self.window close ];
}

- ( IBAction )save: ( id )sender
{
    NSUserDefaults * defaults;
    
    defaults = [ NSUserDefaults standardUserDefaults ];
    
    ( void )sender;
    
    if( [ _loginCheckbox integerValue ] == 1 && [ self isLoginItemEnabled ] == NO )
    {
        [ self enableLoginItem ];
    }
    else if( [ _loginCheckbox integerValue ] == 0 && [ self isLoginItemEnabled ] == YES )
    {
        [ self disableLoginItem ];
    }
    
    [ defaults setBool:    ( BOOL )[ _autoPurgeCheckbox integerValue ] forKey: @"AutoPurge" ];
    [ defaults setBool:    ( BOOL )[ _idleCheckbox      integerValue ] forKey: @"Idle" ];
    [ defaults setInteger: [ _autoPurgeSlider           integerValue ] forKey: @"AutoPurgeTime" ];
    [ defaults setInteger: [ _idleSlider                integerValue ] forKey: @"IdleTime" ];
    
    [ defaults synchronize ];
    [ self.window close ];
    [ [ NSNotificationCenter defaultCenter ] postNotificationName: PreferencesChangedNotification object: nil ];
}

- ( IBAction )toggleAutoPurgeSlider: ( id )sender
{
    if( sender != _autoPurgeCheckbox )
    {
        return;
    }
    
    if( [ sender integerValue ] == 0 )
    {
        [ _autoPurgeSlider setEnabled: NO ];
    }
    else
    {
        [ _autoPurgeSlider setEnabled: YES ];
    }
}

- ( IBAction )toggleIdleSlider: ( id )sender
{
    if( sender != _idleCheckbox )
    {
        return;
    }
    
    if( [ sender integerValue ] == 0 )
    {
        [ _idleSlider setEnabled: NO ];
    }
    else
    {
        [ _idleSlider setEnabled: YES ];
    }
}

- ( IBAction )showWindow: ( id )sender
{
    NSUserDefaults * defaults;
    
    defaults = [ NSUserDefaults standardUserDefaults ];
    
    [ _loginCheckbox     setIntegerValue: [ self isLoginItemEnabled ] ];
    [ _autoPurgeCheckbox setIntegerValue: [ defaults boolForKey:    @"AutoPurge" ] ];
    [ _idleCheckbox      setIntegerValue: [ defaults boolForKey:    @"Idle" ] ];
    [ _autoPurgeSlider   setIntegerValue: [ defaults integerForKey: @"AutoPurgeTime" ] ];
    [ _idleSlider        setIntegerValue: [ defaults integerForKey: @"IdleTime" ] ];
    [ _autoPurgeText     setIntegerValue: [ defaults integerForKey: @"AutoPurgeTime" ] ];
    [ _idleText          setIntegerValue: [ defaults integerForKey: @"IdleTime" ] ];
    
    if( [ _autoPurgeCheckbox integerValue ] == 0 )
    {
        [ _autoPurgeSlider setEnabled: NO ];
    }
    
    if( [ _idleCheckbox integerValue ] == 0 )
    {
        [ _idleSlider setEnabled: NO ];
    }
    
    [ super showWindow: sender ];
}

@end
