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

#import "ApplicationDelegate.h"
#import "PreferencesController.h"
#import "AboutController.h"
#import "IdleTime.h"
#import "Execution.h"
#import "Memory.h"

@interface ApplicationDelegate( Private )

- ( void )preferencesChanged;
- ( void )autoPurge;
- ( void )checkIdleTime;
- ( void )updateMemoryUsage;

@end

@implementation ApplicationDelegate( Private )

- ( void )preferencesChanged
{
    NSUserDefaults * defaults;
    
    defaults = [ NSUserDefaults standardUserDefaults ];
    
    [ _timer invalidate ];
    
    _timer = nil;
    
    if( [ defaults boolForKey: @"AutoPurge" ] == YES )
    {
        _timer = [ NSTimer scheduledTimerWithTimeInterval: ( [ defaults integerForKey: @"AutoPurgeTime" ] * 60 ) target: self selector: @selector( autoPurge ) userInfo: nil repeats: YES ];
    }
}

- ( void )autoPurge
{
    NSUserDefaults * defaults;
    
    defaults = [ NSUserDefaults standardUserDefaults ];
    
    if( [ defaults boolForKey: @"Idle" ] == NO )
    {
        [ self purge: nil ];
    }
    else
    {
        if( ( NSInteger )_idleTime.secondsIdle >= [ defaults integerForKey: @"IdleTime" ] )
        {
            [ self purge: nil ];
        }
        else
        {
            [ _timer invalidate ];
            
            _timer = [ NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector( checkIdleTime ) userInfo: nil repeats: YES ];
        }
    }
}

- ( void )checkIdleTime
{
    NSUserDefaults * defaults;
    
    defaults = [ NSUserDefaults standardUserDefaults ];
    
    if( ( NSInteger )_idleTime.secondsIdle >= [ defaults integerForKey: @"IdleTime" ] )
    {
        [ self purge: nil ];
        [ _timer invalidate ];
        
        _timer = [ NSTimer scheduledTimerWithTimeInterval: ( [ defaults integerForKey: @"AutoPurgeTime" ] * 60 ) target: self selector: @selector( autoPurge ) userInfo: nil repeats: YES ];
    }
}

- ( void )updateMemoryUsage
{
    Memory * memory;
    
    memory = [ Memory sharedInstance ];
    
    [ _statusMenuItemTotal      setTitle: [ NSString stringWithFormat: NSLocalizedString( @"memoryTotal", nil ),    memory.total ] ];
    [ _statusMenuItemWired      setTitle: [ NSString stringWithFormat: NSLocalizedString( @"memoryWired", nil ),    memory.wired ] ];
    [ _statusMenuItemActive     setTitle: [ NSString stringWithFormat: NSLocalizedString( @"memoryActive", nil ),   memory.active ] ];
    [ _statusMenuItemInactive   setTitle: [ NSString stringWithFormat: NSLocalizedString( @"memoryInactive", nil ), memory.inactive ] ];
    [ _statusMenuItemFree       setTitle: [ NSString stringWithFormat: NSLocalizedString( @"memoryFree", nil ),     memory.free ] ];
}

@end

@implementation ApplicationDelegate

@synthesize statusMenu             = _statusMenu;
@synthesize statusMenuItemTotal    = _statusMenuItemTotal;
@synthesize statusMenuItemWired    = _statusMenuItemWired;
@synthesize statusMenuItemActive   = _statusMenuItemActive;
@synthesize statusMenuItemInactive = _statusMenuItemInactive;
@synthesize statusMenuItemFree     = _statusMenuItemFree;

- ( void )applicationDidFinishLaunching: ( NSNotification * )notification
{
    NSUserDefaults * defaults;
    NSImage        * statusIcon;
    NSImage        * statusIconAlt;
    NSBundle       * bundle;
    
    ( void )notification;
    
    [ self updateMemoryUsage ];
    
    defaults   = [ NSUserDefaults standardUserDefaults ];
    _idleTime  = [ IdleTime new ];
    
    [ defaults registerDefaults: [ NSDictionary dictionaryWithContentsOfFile: [ [ NSBundle mainBundle ] pathForResource: @"Defaults" ofType: @"plist" ] ] ];
    
    bundle         = [ NSBundle mainBundle ];
    statusIcon     = [ [ NSImage alloc ] initWithContentsOfFile: [ [ NSBundle mainBundle ] pathForResource: @"StatusItem" ofType: @"pdf" ] ];
    statusIconAlt  = [ [ NSImage alloc ] initWithContentsOfFile: [ [ NSBundle mainBundle ] pathForResource: @"MenuItem-On" ofType: @"tif" ] ];
    _statusItem    = [ [ [ NSStatusBar systemStatusBar ] statusItemWithLength: NSSquareStatusItemLength  ] retain ];
    
    [ _statusItem setImage: statusIcon ];
    [ _statusItem setAlternateImage: statusIconAlt ];
    [ _statusItem setMenu: _statusMenu ];
    [ _statusItem setHighlightMode: YES ];
    
    [ statusIcon release ];
    [ statusIconAlt release ];
    
    [ [ NSNotificationCenter defaultCenter ] addObserver: self selector: @selector( preferencesChanged ) name: PreferencesChangedNotification object: nil ];

    if( [ defaults boolForKey: @"AutoPurge" ] == YES )
    {
        _timer = [ NSTimer scheduledTimerWithTimeInterval: ( [ defaults integerForKey: @"AutoPurgeTime" ] * 60 ) target: self selector: @selector( autoPurge ) userInfo: nil repeats: YES ];
    }
    
    _memoryUsageTimer = [ NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector( updateMemoryUsage ) userInfo: nil repeats: YES ];
}

- ( void )applicationWillTerminate: ( NSNotification * )notification
{
    ( void )notification;
    
    [ _timer                    invalidate ];
    [ _memoryUsageTimer         invalidate ];
    [ _preferencesController    release ];
    [ _aboutController          release ];
    [ _statusMenu               release ];
    [ _statusMenuItemTotal      release ];
    [ _statusMenuItemWired      release ];
    [ _statusMenuItemActive     release ];
    [ _statusMenuItemInactive   release ];
    [ _statusMenuItemFree       release ];
    [ _idleTime                 release ];
    [ _exec                     release ];
}

- ( IBAction )purge:( id )sender
{
    NSTask * task;
    
    ( void )sender;
    
    task            = [ [ NSTask alloc ] init ];
    task.launchPath = @"/usr/bin/purge";
    
    [ task launch ];
    [ task release ];
}

- ( IBAction )purgeAsAdmin:( id )sender
{
    ( void )sender;
    
    if( _exec == nil )
    {
        _exec = [ Execution new ];
    }
    
    [ _exec executeWithPrivileges: ( char * )[ @"/usr/bin/purge" cStringUsingEncoding: NSUTF8StringEncoding ] arguments: NULL io: NULL ];
}

- ( IBAction )openPreferences:( id )sender
{
    if( _preferencesController == nil )
    {
        _preferencesController = [ PreferencesController new ];
    }
    
    [ _preferencesController.window center ];
    [ _preferencesController.window makeKeyAndOrderFront: sender ];
    [ NSApp activateIgnoringOtherApps: YES ];
    [ _preferencesController showWindow: sender ];
}

- ( IBAction )openAboutWindow:( id )sender
{
    if( _aboutController == nil )
    {
        _aboutController = [ AboutController new ];
    }
    
    [ _aboutController.window center ];
    [ _aboutController.window makeKeyAndOrderFront: sender ];
    [ NSApp activateIgnoringOtherApps: YES ];
    [ _aboutController showWindow: sender ];
}

- ( IBAction )quit:( id )sender
{
    [ NSApp terminate: sender ];
}

@end
