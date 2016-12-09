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

@class MenuController;
@class PreferencesController;
@class AboutController;
@class IdleTime;
@class Execution;

@interface ApplicationDelegate: NSObject < NSApplicationDelegate >
{
@protected
    
    NSStatusItem          * _statusItem;
    NSMenu                * _statusMenu;
    NSMenuItem            * _statusMenuItemTotal;
    NSMenuItem            * _statusMenuItemWired;
    NSMenuItem            * _statusMenuItemActive;
    NSMenuItem            * _statusMenuItemInactive;
    NSMenuItem            * _statusMenuItemFree;
    PreferencesController * _preferencesController;
    AboutController       * _aboutController;
    NSTimer               * _timer;
    NSTimer               * _memoryUsageTimer;
    IdleTime              * _idleTime;
    Execution             * _exec;
    
@private
    
    id _MemoryPurgeAppDelegate_Reserved[ 5 ] __attribute__( ( unused ) );
}

@property( nonatomic, retain ) IBOutlet NSMenu     * statusMenu;
@property( nonatomic, retain ) IBOutlet NSMenuItem * statusMenuItemTotal;
@property( nonatomic, retain ) IBOutlet NSMenuItem * statusMenuItemWired;
@property( nonatomic, retain ) IBOutlet NSMenuItem * statusMenuItemActive;
@property( nonatomic, retain ) IBOutlet NSMenuItem * statusMenuItemInactive;
@property( nonatomic, retain ) IBOutlet NSMenuItem * statusMenuItemFree;

- ( IBAction )purge:( id )sender;
- ( IBAction )purgeAsAdmin:( id )sender;
- ( IBAction )openPreferences:( id )sender;
- ( IBAction )openAboutWindow:( id )sender;
- ( IBAction )quit:( id )sender;

@end
